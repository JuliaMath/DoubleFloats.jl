# SIMD implementation guide for elementary functions

This guide records the original implementation plan and prototype
measurements. The implemented API, dispatch ranges, and checked
measurements are in the [User Guide](src/userguide.md#elementwise-operations-on-vectors)
and [Technical Guide](src/technicalguide.md#elementary-vector-kernels).
The repeatable driver is [benchmark/studies/bench_simd_elementary.jl](../benchmark/studies/bench_simd_elementary.jl).
The [follow-up guide](vecbetter.md) records the wider ranges and new
vector operations added after this rollout.

## Scope and evidence

Implement opt-in batch evaluation for the 71 operation and overload cases measured in `trig.jl`, `arctrig.jl`, `hyptrig.jl`, `archyptrig.jl`, `explog.jl`, and `complex.jl`. The initial native kernels target `Double64` and `ComplexDF64`. Existing scalar methods define the numerical contract. Other precisions can use their scalar methods through the same vector interface.

The evidence comes from revision `d68a1c0c`, Julia 1.13.3, and an Intel Core i9-14900K. The 48 bounded prototypes emitted SIMD loops and matched all result limbs on their sampled inputs. Their gains below compare preallocated scalar broadcast and bounded kernels on 4,096 elements. Most omit classification and repair, so the figures describe the kernel opportunity. The checked small-angle prototypes retained about 3.7–3.8× for `sin`, `cos`, and `tan` with about 1% fallback. The separate general-range experiment used 65,536 elements. Adding `@simd` around existing scalar methods generally did little, while four threads gave a median 3.91× gain across all 71 cases. These are workload-specific measurements. Reproduce the bounded and general-range baselines before evaluating production changes.

## 1. Add a shared vector entry point

Use an opt-in interface such as `DoubleFloats.simdmap!(f, dest, args...; threaded=false)`. Choose the final name once and use it consistently in tests and documentation. Keep the function qualified initially. It should return `dest`, accept one or two vector operands, and support a scalar second operand for power. Require all vector axes to match the destination before any write. Treat a scalar exponent as a constant across the batch. Tuple-valued functions write tuples to a single output vector. This API is elementwise and has no general broadcasting or array-shape expansion.

- Dispatch once on the function, operand types, and output representation. Specialize the native loop for dense contiguous inputs and outputs with supported concrete element types. Use the existing scalar methods for strided views, unsupported storage, narrow destination conversions, unknown callables, or sizes below the measured crossover.
- Define overlaps by source-at-entry semantics. Conservative `Base.mightalias` checks can send potentially overlapping vectors through the scalar path with copies of aliased operands. If a custom vector cannot reliably report aliasing, snapshot its values before writing. Preserve its index mapping in the fallback. A later optimization can support exact in-place operation when the index mapping is known and repair cannot reread an overwritten value. Start with the same conservative handling for unary, binary, and scalar-argument cases.
- Keep ordered scalar behavior as the default, including domain errors and signed zeros. In serial mode the destination prefix before a failing element should match the scalar loop. For a block that may contain a throwing lane or a result that cannot be stored, process in index order using the scalar path or valid runs separated by scalar calls. Safe SIMD lanes must have a destination element type that can hold their result without a throwing conversion. In particular, `cis` returns a real value for a NaN input in the current scalar implementation.
- Provide explicit threading for supported pure numerical operations on disjoint writable chunks. Initially use static-sized contiguous chunks and a measured crossover per cost class. Allow calls from worker threads by using a scheduler that supports nested callers or by falling back to single-threaded execution in nested contexts. Document that failures can be reported via task exceptions and other chunks may already have written. Callers who need ordered exception behavior use the default mode. Unknown user callbacks use the ordered scalar path.
- Put public dispatch, alias handling, blocking, and threading in one new file under `src/math/elementary/`, included from [DoubleFloats.jl](../src/DoubleFloats.jl) after the scalar elementary methods. Keep each arithmetic kernel in its owning file. Reuse the transformations in [errorfree.jl](../src/math/errorfree.jl) and `src/math/ops/`. Keep the work independent of Base broadcasting hooks and of matrix-kernel dispatch.

## 2. Separate lane classification from arithmetic

Implement an all-eligible fast route first, then compare per-lane repair against scalar handling of mixed blocks. A block of 64 aligns with one `UInt64` mask and worked in the prototype. Benchmark smaller and larger blocks on the supported targets.

1. Classify each lane once for the specific native regime. The predicate must establish that the operands and all unchecked intermediates satisfy the scalar kernel's assumptions. Inspect both limbs. The raw two-limb constructor accepts pairs outside ordinary normalized form. Either prove the kernel is equivalent on such inputs or screen them and delegate to the scalar method. Use bit-based or bounded checks where they are equivalent to the required range test, and measure their cost. Include equality endpoints only after proving the scalar method takes the matching path.
2. On an all-eligible block, run the inlined native kernel in a bounds-check-free loop. Extract shared unchecked functions from the scalar source where practical so coefficients and operation order have one owner. Keep guards in the public scalar wrapper. Never apply `@fastmath` or reassociation to error-free transforms. Let LLVM vectorize and check the emitted loop.
3. For sparse nonthrowing exceptions on disjoint arrays, replace excluded lanes with a safe input **before** any unchecked arithmetic. Store the native results and then repair excluded indices by calling the original scalar operation on the original operands. A safe placeholder must satisfy that kernel's domain, including denominators and every nested sub-kernel. Use the same scratch-free scheme for tuple or complex results when the destination is suitable.
4. For several native regimes such as direct and table logarithms, add the second regime only after measuring a need. An all-one-regime block can run its own kernel. Mixed blocks can use scalar repair from the dominant regime or use separate masked runs if their cost is justified. If few lanes qualify, skip the SIMD pass. Guard rejection must never by itself change the result or report a domain error.
5. Use the interleaved `DoubleFloat` representation first. The prototypes vectorized it directly. Test split high/low planes only when output throughput or reuse across operations can pay for packing. For `ComplexDF64`, measure any plane split end to end, including repacking both components.

## 3. Implement and validate each family

Each row below assigns an initial route to the functions measured in the survey. The general scalar fallback and explicit threaded execution apply to every row. The intervals below describe benchmark fixtures. Production predicates still need to prove each intermediate stays inside the chosen scalar branch, including the effect of either sign of the low limb.

### Exponentials, logarithms, and powers

Keep these kernels in [explog.jl](../src/math/elementary/explog.jl). This family comes first because the real and complex compositions reuse it.

For initial reproduction, use `(0.55, 16)` for the ordinary exponentials, `(0.032, 0.06)` for the fixed-binade `expm1` path, `(0.95, 1.05)` for the direct logarithms, `(1.1, 4)` for the table logarithms, and `(0.005, 0.05)` for direct `log1p`. The power prototypes used bases from 0.5 to 1.5 with fixed exponent 5 and bases from 1.1 to 1.5 with noninteger exponents from 0.2 to 0.9.

| Operation | Initial native path | Required scalar handling |
| --- | --- | --- |
| `exp2` | Use `_exp2_reduced` and `_exp2_scale` over checked ordinary inputs. Start from the measured regime and expand to finite normal-output arguments after checking the low limb and boundary agreement. | Keep the existing exact-zero result, overflow clamp, guaranteed-underflow return, subnormal lattice rounding, NaN handling, and midpoint refinement. For zero-dominated blocks, compare scalar returns with a dedicated proven-zero fill before enabling a polynomial pass. |
| `exp`, `exp10` | Use the same base-2 loop and a bounded version of `_mf_mul3` that preserves all three converted limbs and the scalar operation order. Choose conservative input bounds for each base and prove the converted result stays on the ordinary path. Measure each separately. | Preserve converted-argument cutoffs and the original two limbs for scalar midpoint resolution. Keep Double32 promotion and its Float32 underflow dispatch on the scalar path. Avoid repeated conversion solely for screening unless it pays in measurement. |
| `log2`, `log`, `log10` | Extract the direct kernel for heads strictly between 15/16 and 17/16. Add the separate table path for positive finite inputs outside that range. Keep existing table indices, low-limb exponent guards, and final base conversion. The prototypes measured about 4.2× direct and 3.9× table. | Route near-zero, signed-zero, negative, nonfinite, and unusual limb pairs to scalar evaluation until their behavior is covered. Benchmark repeated table indices and widely varying ones, plus vectors crossing the direct/table boundary. |
| `log1p` | Use the direct `x/(2+x)` kernel inside the scalar window, initially away from zero and with conservatively bounded low limbs. | Preserve signed zero, the exact negative endpoint, domain errors, and scalar addition before logarithm outside the direct window. |
| `expm1` | For `abs(HI(x)) >= 0.5` and normal exponential outputs, use the ordinary exponential kernel followed by the same subtraction. For smaller inputs specialize one measured binade at a time. Use a fixed count of the same Taylor and doubling steps for a binade, with bounded unrolling. | Keep signed zero, nonfinites, and the adaptive reconstruction for other binades and mixed blocks where partitioning loses. Benchmark code size and first use before adding more binades. |
| `^(Double64, Int)` | Specialize a small set of common scalar exponents, beginning with 5. Preserve the scalar multiplication and squaring order. Compare against both `x -> x^5` and a vector call with a scalar exponent. The 13× figure is for fixed 5. | Use scalar exponentiation by squaring for varying integer exponents, unsupported scalar exponents, negative exponent edge cases, and unusual bases. Keep zero-exponent and reciprocal behavior. Limit value specialization to the allowlist. |
| `^(Double64, Double64)` | For positive bounded bases and noninteger exponents, compose the checked logarithm, multiplication, and ordinary exponential in the scalar order. Stage eligibility checks on the product or prove it stays inside the exponential envelope. | Preserve the scalar integer detection and delegation, negative-base and zero-base behavior, range errors, and underflow. Benchmark mixtures of integral and nonintegral exponent lanes. |

### Circular and inverse circular functions

Keep the kernels in [trig.jl](../src/math/elementary/trig.jl) and [arctrig.jl](../src/math/elementary/arctrig.jl). Preserve the current high-precision range reduction near roots and poles.

Reproduce the circular kernels on `(0.005, 0.09)` radians and unary `atan` on `(0.005, 0.19)`. The fixed-degree `atan` prototype reached 5.1× after unrolling.

| Operation | Initial native path | Required scalar handling |
| --- | --- | --- |
| `sin`, `cos` | Inline the relevant result of the shared small-angle Taylor core. Use the verified positive window first. Extend to negative angles by matching the exact scalar sign and absolute-value handling, then test both sides of zero. | Scalar at signed zero and outside the proved Taylor window. Develop quadrant reduction and sector lookup separately, using the existing three-limb constants and root-specific reductions. |
| `sincos` | Compute one Taylor pair and write a tuple. Reuse the same range checks as `sin` and `cos`, respecting the paired scalar method's sign conventions. | Preserve both components for zeros, NaN, and domain errors. For extended ranges, keep one shared reduction and reconstruction. |
| `cis` | Build the complex result from the matched cosine and sine. Test both component signs, including the contribution from adding the imaginary term in the scalar expression. | Preserve the existing NaN return and destination conversion behavior. Use the scalar path for signed zero, unsupported output types, and large arguments. |
| `tan` | Compute the checked sine/cosine pair and use the existing double-word quotient in the verified small-angle band. The band guarantees the denominator stays away from zero. | Keep the scalar `Float128` route near poles and for large arguments. In any extended SIMD range, reproduce the scalar `abs(HI(c)) < 0.1` fallback rule after reduction. |
| `cot` | Use the scalar result's reciprocal of the checked `tan` path after proving the original `mod1pi` near-root guard cannot fire. Start in the measured window away from zero. | Keep the existing near-multiple-of-π check and large-argument handling. |
| `sinpi`, `cospi`, `tanpi`, `sincospi`, `cispi` | Offer scalar batching and explicit threading. These operations still depend on `Float128` implementations. | Treat a native pi-scaled algorithm as separate work. It must preserve integer and half-integer cases, signed zero, exact signs, and accuracy at large arguments. Rewriting as a multiply by π followed by ordinary trig loses this contract. |
| Unary `atan` | Start with the proved positive small-argument window, using the existing halving, square root, reciprocal, and fixed-degree polynomial. Unroll the fixed Horner loops if the default compiler leaves a scalar loop. Keep the square-root primitive restricted to positive finite intermediates. | Preserve zero, infinities, NaN, the sign rule, the inversion branch, and the other angle reductions. Add those branches only with measured benefit and scalar agreement. |
| `asin`, `acos`, `acsc`, `asec`, `acot` | Offer scalar batching and explicit threading through the existing `Float128` methods. | A native approximation is separate numerical development. Domain endpoints and near-endpoint accuracy need independent validation. |
| Binary `atan(y,x)`, `atanxy(x,y)` | Use threaded or serial scalar evaluation of the existing `Float128` two-argument method. Make `atanxy` forward with the same reversed argument order. | Preserve quadrants, signed zeros, and infinities. Unary `atan(y/x)` alone cannot reproduce those cases. |

### Hyperbolic and inverse hyperbolic functions

Keep the compositions in [hyptrig.jl](../src/math/elementary/hyptrig.jl) and [archyptrig.jl](../src/math/elementary/archyptrig.jl). Reuse the exponential, logarithm, and bounded arithmetic kernels rather than making intermediate arrays.

The inverse prototypes used `(0.005, 0.045)` for `asinh`, `(1.00002, 1.001)` for `acosh`, `(0.005, 0.025)` for `atanh`, `(30, 50)` for `acsch`, `(0.999, 0.99998)` for `asech`, and `(40, 100)` for `acoth`.

| Operation | Initial native path | Required scalar handling |
| --- | --- | --- |
| `sinh`, `cosh` | Start with positive arguments in the measured 1.1–5 range. Form `exp(x)` and its reciprocal, then the scalar sum or difference and half scaling. Share the pair in consumers of both results. | Keep the small `sinh` `expm1` branch, signs, zero, large-argument shortcuts, and `Float128` overflow bridge. Expand ranges independently after checking subtraction or overflow headroom. |
| `tanh` | Use the ordinary positive branch with `exp(-2x)` and the scalar quotient. | Retain the small-argument `expm1` form and large or nonfinite behavior. |
| `csch`, `sech` | Take the existing reciprocal of the bounded `sinh` or `cosh` result. | Preserve signed limits and avoid reciprocal of zero or a near-underflow intermediate in the native path. |
| `coth` | Share bounded sine-hyperbolic and cosine-hyperbolic work, then apply the scalar division. Verify both limbs before sharing `exp(x)` and its reciprocal. | Keep the singularity, saturation, and scalar special-value paths. Avoid a different quotient identity merely to simplify vectorization. |
| `asinh` | Use the small positive composition of square, square root, division, and direct `log1p`. Prove the composed `log1p` argument is inside its direct window, including low limbs. | Preserve sign and large-input asymptotic branch. Fall back before any intermediate can overflow. |
| `acosh` | Near one, keep the scalar difference `u = x - 1`, then `log1p(u + sqrt(u*(2+u)))` with positive bounded intermediates. | Keep exact one, domain errors, nonfinites, and the large-input logarithm shortcut. |
| `atanh` | Use the verified small positive branch, including the scalar mixed-float subtraction used in the denominator. | Keep sign, endpoints, negative values until their sign path is verified, and the two-logarithm branch. |
| `acsch` | Apply the scalar-order reciprocal and then the supported small-`asinh` kernel. The prototype used inputs from 30 to 50. | Keep singular, nonfinite, and out-of-window inputs in the scalar path. |
| `asech` | Near one, form `v = (1-x)/x` in scalar order and use its bounded direct `log1p` composition. | Keep zero, invalid inputs, and the large-`v` branch. |
| `acoth` | Use the verified large-positive window from 40 to 100. Preserve the scalar mixed-precision reciprocal and multiply sequence in `2/(x-1)` and the subsequent `log1p`. | Keep the domain gap, endpoints, and sign handling. A double-word division substituted for the scalar mixed-float expression can change the low limb. |

### Complex functions

Keep bounded compositions in [complex.jl](../src/math/elementary/complex.jl). Begin with the measured rectangles in the table. Check all reductions and intermediates, including doubled components. Preserve the scalar formulas and rounding order, complex zeros, infinities, NaN behavior, branch cuts, and choices on opposite sides of the cuts.

| Operation | Initial native path and measured window |
| --- | --- |
| `square`, `abs2` | Use bounded real squares and the existing addition or subtraction and product order for both limbs. Start with real parts from 1.1 to 5 and imaginary parts in the small positive trigonometric window below. Expand with a proof for intermediate overflow and underflow. |
| `exp` | Compute the ordinary real exponential once and share the imaginary sine/cosine pair, then multiply in scalar order. Start with real part 1.1–5 and imaginary part 0.005–0.09. |
| `sin`, `cos` | Share the real sine/cosine pair with real part 0.005–0.09 and use the imaginary hyperbolic pair for imaginary part 1.1–5. Preserve product and sign order. |
| `sinh`, `cosh` | Use the hyperbolic pair on real part 1.1–5 and the trigonometric pair on imaginary part 0.005–0.09. |
| `tan`, `cot` | Use the same scalar double-angle denominator and divisions, starting with real part 0.005–0.045 and imaginary part 1.1–5. Prove the denominator remains finite and separated from zero. |
| `csc`, `sec` | Use their scalar single- and double-angle formulas in the previous rectangle. Dispatch on `DoubleFloats.csc` and `DoubleFloats.sec`, the distinct module-local functions defined here. Unqualified Base functions follow other methods. |
| `tanh`, `coth`, `csch`, `sech` | Use the double-angle denominators with real part 1.1–5 and imaginary part 0.005–0.045. Retain the scalar order of numerator products, divisions, and signs. |
| `sqrt`, `log` | Offer scalar batching and explicit threading. `sqrt` routes through complex `Float128`. `log` uses the native magnitude calculation and a `Float128` phase. Benchmark staging the components before considering a split native kernel. |
| `asin`, `acos`, `atan`, `acsc`, `asec`, `acot` | Offer scalar batching and explicit threading through the composite kernels. Reassess after real atan, logarithm, and square-root work pays off. Any new native path needs separate branch-cut tests. |
| `asinh`, `acosh`, `atanh`, `acsch`, `asech`, `acoth` | Offer scalar batching and explicit threading through the existing compositions. Stage real subexpressions only if a full-vector benchmark shows a net gain. |
| `csgn` | Keep as a small internal binary helper. Measure inlining it where used before giving it separate dispatch or a threaded threshold. |

For compositions that use doubled hyperbolic arguments above 5, prove the ordinary hyperbolic kernel is valid throughout the extended inner range up to 10 before enabling these rectangles. Some complex prototypes already exercised those inner values. Validate both the inner real functions and the final complex result.

## 4. Verify correctness before measuring gains

Add `test/simd_elementary.jl` to [runtests.jl](../test/runtests.jl). Use deterministic fixtures and independent reference checks.

1. Compare both limbs of each result against a scalar loop for every enabled kernel. Apply the comparison recursively to tuples and complex numbers. Check signed zeros and NaN classification explicitly. Match the scalar method's natural result type before the destination's assignment conversion and preserve the scalar exception type in serial mode. Use independent high-precision references at difficult boundaries to detect a shared numerical regression.
2. Test each eligible window just inside, at, and just outside its endpoints with both signs of the low limb. Include normalized and unusual raw pairs, exponent extremes, underflow midpoints, log domain boundaries, trig poles, complex branch cuts, and mixed finite and special values. Deliberately reach each production branch used by the benchmark.
3. Test empty vectors, singleton and very short vectors, exact block sizes, tails, dense and strided views, axis mismatch before any write, exact aliasing, shifted overlaps in both directions, and binary cases with only one aliased operand. Verify ordered serial exceptions and destination writes before the exception. Check unsupported element and result types through the fallback.
4. Run the same numerical suite with one thread and the threaded variant. Include calls from worker threads, more workers than elements, and chunk boundaries near the tail. Compare scalar behavior on valid input and test the documented threaded error behavior independently.
5. Run the full package suite on Julia 1.10 and a current supported Julia version. Verify that scalar inference, allocations, and representative scalar timings survive kernel extraction. Inspect successful kernels for vector arithmetic across elements. Packed high/low operations within a single element are insufficient evidence of loop vectorization.

## 5. Benchmark admission and rollout

Put a repeatable driver in `perf/`. Record the Julia version, CPU and target features, thread count, seed, input range, result representation, and commit. Benchmark each enabled function and overload against the pre-change scalar broadcast, the new API's scalar fallback, and the checked SIMD and optional threaded dispatch. Keep fixture creation outside timed loops and consume preallocated outputs.

| Experiment | Required comparisons |
| --- | --- |
| Vector size and storage | Test 0, 1, a few lanes, several sizes around the block and thread crossovers, 4,096, 65,536, and a size beyond cache. Include output type variants, views, and aliasing fallback. |
| Input mixtures | Use 0%, about 1%, 10%, 50%, and 100% fallback inputs. Compare clustered and shuffled distributions. For multiple native regimes, vary the split and location of boundaries. Report pole, subnormal, and MPFR costs separately. |
| Scaling and allocations | Measure one thread and representative worker counts including four. Report median and spread from repeated interleaved comparisons. Record bytes and allocations, including alias copies, scheduling, and MPFR repair. Assert no allocations for disjoint dense single-threaded ordinary workloads. |
| Compilation and portability | Measure first-call latency in fresh processes, inspect hot-loop LLVM, and verify throughput without AVX-512 where possible. Limit value specialization and unrolling when generated code size or cold latency outweighs the gain. |
| Acceptance | Require a repeatable end-to-end improvement on the intended workloads after classification and repair. Keep a scalar threshold or disable a regime if the checked version loses at relevant sizes. Report fully exceptional and scalar-caller regressions separately. Treat bounded prototype ratios as references for the arithmetic only. |

Land shippable steps in dependency order.

1. Add the opt-in API, scalar fallback, alias and exception tests, and benchmark driver. Establish caller-side threaded gains for every measured operation before tuning thread thresholds.
2. Add the shared block loop and `exp2`. Compare checked all-ordinary, per-lane repair, and whole-block fallback. Add `exp`, `exp10`, the two logarithm regimes, `log1p`, `expm1`, and verified power paths as separate benchmarkable changes.
3. Add the small-angle trigonometric kernel and bounded `atan`. Extend to the real hyperbolic families once the exponential, logarithm, and guarded arithmetic components are available.
4. Add verified complex compositions, starting with arithmetic and `exp`. Run the mixed-input and alias matrix tests for each group. Keep the branch-heavy and `Float128` operations on the scalar or threaded driver until they have independently verified native algorithms.
5. Update the User Guide and Technical Guide with the finalized API, supported paths, threading and alias rules, and checked benchmark results. Treat wider trigonometric reduction, additional precisions, and more native inverse or complex functions as later changes with their own evidence.
