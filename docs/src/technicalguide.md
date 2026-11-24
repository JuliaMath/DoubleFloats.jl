# Technical Guide

How DoubleFloats represents numbers and which algorithms sit behind the
public functions.  For guidance on extending the package, see
[Adding New Functions](addingfunctions.md).

## Representation as an unevaluated sum

A `DoubleFloat{T}` holds two floats, `hi` and `lo`, whose *unevaluated
sum* is the represented value:

```
value = hi + lo,   with   |lo| ≤ ulp(hi)/2
```

`hi` is the value rounded to `T`; `lo` is the leading part of the
rounding error.  For `Double64` this gives a nominal 106-bit significand
(2 × 53), about 32 decimal digits. The reports use `2^-104` as a
relative working-precision unit. See
[Representation and precision](characteristics.md) for the supported types.

Two structural consequences matter throughout the package:

- **The exponent range is that of `T`.**  Overflow and underflow happen
  on the scale of the underlying type.
- **Precision degrades near the bottom of the range.**  When
  `|value| < ~4e-292`, the `lo` word is subnormal and the effective
  precision tapers below 106 bits; below `~1e-308` only `Float64`
  precision remains.  This is a *representation* limit — visible, for
  example, in `exp(x)` for `x < -670` — and no algorithm returning a
  `Double64` can beat it.

## Error-free transformations

Scalar arithmetic uses building blocks from `src/math/errorfree.jl`.
Their error-free identities assume finite inputs and representable
intermediate results and residuals.

- `two_sum(a, b)` / `two_hilo_sum(a, b)`: `hi + lo == a + b` exactly.
- `two_prod(a, b)`: `hi + lo == a * b` exactly, using `fma`.
- Division and square root use these plus one Newton-like correction
  (`src/math/ops/`) to recover low bits. Operations returning one
  DoubleFloat can still round.

A zero low word describes the input pair. The output can still need a
low word, as happens when taking the reciprocal of `Double64(3.0)`.

## Elementary function algorithms

**Exponential functions** (`src/math/elementary/explog.jl`). The shared
base-2 kernel reduces the exponent to `n + 8r` with `|r| ≲ 1/16`.
It evaluates a tapered polynomial for `2^r` using fused Horner steps,
squares three times, and reconstructs with a split power-of-two scale.
`exp` and `exp10` use three-limb base conversion on the native path.

Inputs safely below the zero-rounding threshold bypass the polynomial.
In the underflow band, both reduced limbs contribute to rounding on the
target format's subnormal grid. If the error bound overlaps a rounding
midpoint, the fallback evaluates the original input with directed MPFR
rounding and increases precision until the bounds agree. An exact input
sum lets one downward evaluation and its next representable MPFR value
bound an inexact result. The fallback compiles on first use. Ordinary
`Double32` calls to `exp` promote through `Double64`, with direct
rounding to the `Float32` grid in the underflow band.

**Logarithms**. The `log2` kernel decomposes a positive input into an
exponent and a mantissa. It uses 32 exact table centers `c` and a
polynomial in `t²`, where `t = (m-c)/(m+c)` for mantissa `m`.
Near one it uses `t = (x-1)/(x+1)` directly to preserve the small
result. The table path rescales tiny inputs and checks both source and
destination exponent fields before adjusting the low limb's exponent.
This matters even when the low limb starts out normal. `log` and
`log10` convert the `log2` result to their respective bases.

**`log1p` and `expm1`**. Near zero, `log1p` uses
`log(1+x) = 2·atanh(x/(2+x))`. `expm1` evaluates a Taylor series on
a scaled argument and reconstructs with the doubling identity
`expm1(2t) = expm1(t)·(expm1(t) + 2)`.

**Cube root and fused multiply-add**. Scalar `cbrt` returns a
`DoubleFloat`. For extreme `Double64` inputs it scales both limbs by
`2^(-3k)` before Newton refinement and scales the root by `2^k`
afterward. This keeps intermediate products in range and retains the
input's low-limb contribution at working precision. Near cancellation,
`fma` and `muladd` for three `Double64` operands refine the result
with an allocation-free expansion. Its tuple capacity grows one slot
at a time as product and addend terms are inserted.

**Trigonometric functions** (`trig.jl`): argument reduction by `mod2pi`,
then circle-splitting into `[0, π/32]` segments with tabulated
`sin`/`cos` anchor values and short Taylor kernels.  Reductions near the
roots (`x - π/2`, `x - π`) carry a triple-double π so cancellation does
not eat the low word.  Branch windows must be *bounded*: each Taylor
kernel is only valid for `|r| ≤ π/32`.

**Hyperbolics**: from `exp(±x)`; `sinh`/`cosh` switch to a `Float128`
route above 709 where `exp` alone would overflow although they remain
finite (through `ln(2·floatmax) ≈ 710.476`).

**Inverse hyperbolics** (`archyptrig.jl`): formulated to keep relative
precision at their sensitive points, and to avoid squaring overflow:

| function | small/near-1 form | large-argument form (`≥ 4/eps`) |
|:---------|:------------------|:--------------------------------|
| `asinh` | `log1p(x + x²/(1+√(1+x²)))` | `log(x) + ln2` |
| `acosh` | `log1p(u + √(u(2+u)))`, `u = x-1` exact | `log(x) + ln2` |
| `atanh` | `½·log1p(2x/(1-x))` | `½·(log1p(x) - log1p(-x))` for `x > ½` |

`acsch`, `asech`, `acoth` delegate with exactly-formed intermediates
(e.g. `acoth = ½·log1p(2/(x-1))`), never through a bare `inv(x)` where
that would lose `1/x - 1`.

**agm / ellipk** (`src/math/special/`): the AGM iteration stops when the
gap `|a-b|` *stops shrinking* — its quadratic convergence ends exactly at
the roundoff floor — rather than testing a fixed tolerance, which cannot
be chosen correctly in advance for all operand scales.

**erf, erfc, gamma, Bessel**: computed via `Float128` (Quadmath), whose
113-bit significand slightly exceeds `Double64` working precision.

## [Elementary vector kernels](@id elementary-vector-kernels)

The [User Guide](userguide.md#Elementwise-operations-on-vectors) describes
`DoubleFloats.simdmap!`, including axes, overlapping inputs, and exceptions.
The driver checks storage and element types once per call. The batch kernels
reuse the scalar coefficients and error-free transforms without reassociation
or `@fastmath`. They operate on the ordinary interleaved arrays of high and
low limbs.

For a native route, the driver checks both limbs in blocks of up to
32 or 64 elements, depending on the operation. The intervals below
bound the high word. The low word must be
finite and at most half the high word's binade ulp in magnitude. The
bounds leave room for the low limb and nested intermediate operations.
Vectors shorter than 64 elements take the scalar path.

| Input type and operations | Native ranges and result |
|:---|:---|
| `Double64` `exp2` | Heads on −1021 to −0.001 or 0.001 to 1023, where the high word of the result stays normal. |
| `Double64` `exp`, `exp10` | Absolute head from 0.001 to 700 for `exp` and from 0.001 to 300 for `exp10`, with three-limb base conversion. |
| `Double64` `log2`, `log`, `log10` | Direct regime strictly between 15/16 and 17/16. Table regime at or above `2^-915` outside the direct interval, up to the largest finite head. |
| `Double64` `log1p`, `expm1` | `log1p` on 0.005–0.05. `expm1` uses four doublings for absolute heads on `[2^-5, 2^-4)` and ordinary exponential subtraction on 0.5–700. |
| `Double64` power | Scalar `Int` exponent `5` with bases on 0.5–1.5, or vector `Double64` exponents on 0.2–0.9 with bases on 1.1–1.5. |
| `Double64` `sin`, `cos`, `sincos` | Absolute head from 0.005 up to 6.28125 radians, exclusive of the upper bound. `sincos` writes a tuple. |
| `Double64` `tan` | Same head interval, with a 0.11-radian exclusion around the heads of π/2 and 3π/2 in the absolute angle. |
| `Double64` `cis` | Absolute heads on 0.005–0.09 and strictly between the direct Taylor cutoff (approximately 0.09817) and 6.28125. Writes a complex result. |
| `Double64` `hypot`, `DoubleFloats.normalize` | Both absolute heads on 0.25–8. `normalize` writes a tuple in input order. |
| `Double64` `inv` | Absolute head from `2^-256` through `2^256`. |
| `Double64` `cot`, unary `atan` | Positive heads on 0.005–0.09 and 0.005–0.19, respectively. |
| `Double64` hyperbolic functions | `sinh`, `cosh`, `tanh`, `csch`, `sech`, and `coth` on 1.1–5. |
| `Double64` inverse hyperbolic functions | `asinh` on 0.005–0.045, `acosh` on 1.00002–1.001, `atanh` on 0.005–0.025, `acsch` on 30–50, `asech` on 0.999–0.99998, and `acoth` on 40–100. |
| `ComplexDF64` `square`, `abs2`, `exp`, `sinh`, `cosh` | Real head on 1.1–5 and imaginary head on 0.005–0.09. `abs2` writes a real result. |
| `ComplexDF64` `sin`, `cos`, `tan`, `cot`, `DoubleFloats.csc`, `DoubleFloats.sec` | Imaginary head on 1.1–5. Real head on 0.005–0.09 for `sin` and `cos`, or 0.005–0.045 for the other four. |
| `ComplexDF64` `tanh`, `coth`, `csch`, `sech` | Real head on 1.1–5 and imaginary head on 0.005–0.045. |

Mixed blocks normally use the scalar loop, which preserves exception
order. The circular kernels prefer the small-angle route and then
try the wider circular reduction. The wider route reuses the three-limb
π reductions and resolves the table sector using both input limbs.
For `exp2`, `sin`, `cos`, `tan`, and wider `cis`, a block with at most one eighth
of its lanes excluded can SIMD-evaluate safe substitute inputs and then
repair those lanes with the original scalar calls. This requires every
excluded input to pass a wider check that makes the scalar calls and
assignments safe. Blocks containing a potential domain error go through
the scalar loop before any element of the block is written.

The pi-scaled trig functions, binary `atan` and `DoubleFloats.atanxy`,
and the inverse circular functions other than unary `Double64` `atan`
use the existing scalar algorithms inside the batch. The same applies
to complex `sqrt`, `log`, and the inverse complex functions. This preserves
special values, signed zeros, argument quadrants, and complex branch cuts.
Threaded calls use contiguous chunks. Most supported operations are
eligible from 4,096 elements. For `Double64`, `hypot` and paired
`normalize` are eligible from 16,384 elements. Reciprocal and integer
power use a 65,536-element threshold.

### Batch benchmarks

The table reports median microseconds per 4,096 elements from 11 interleaved
measurements. It uses the bounded fixtures in `perf/bench_simd_elementary.jl`,
seed `0x5eed`, Julia 1.13.3, and native AVX2/FMA targeting on an Intel Core
i9-14900K. The baseline is preallocated scalar broadcast from revision
`d68a1c0c`. The batch column includes dispatch and lane checks.

| Operation | Baseline broadcast (µs) | Serial batch (µs) | Speedup |
|:---|---:|---:|---:|
| `sin` | 135.0 | 34.5 | 3.9× |
| `sincos` | 149.7 | 41.4 | 3.6× |
| Unary `atan` | 375.4 | 79.5 | 4.7× |
| `exp2` | 112.9 | 34.7 | 3.3× |
| Fixed-binade `expm1` | 360.0 | 93.9 | 3.8× |
| Table `log` | 110.9 | 33.1 | 3.3× |
| Power with scalar exponent `5` | 41.9 | 5.9 | 7.1× |
| `ComplexDF64` `exp` | 430.6 | 71.2 | 6.0× |

These batch runs used zero heap allocations after compilation. LLVM's
native-target output showed loop vectorization across elements in the
admitted kernels. Julia 1.10.10 with the Haswell target used scalar loops
for some of the same compositions, including tuple-output `sincos` and
vector-exponent power. Performance depends on the compiler and target.
With 1% shuffled out-of-window inputs, sparse repair gave 2.2–2.7×
over scalar broadcast for `sin`, `cos`, `tan`, and `exp2`. The same
fixtures gave 1.4–1.6× when entire mixed blocks used the scalar loop.
Clustered exclusions leave more eligible blocks intact. Fully excluded
fixtures ran near scalar speed. In the separate Julia 1.10.10 exponential
tests, zero-only `exp2` was about 0.9× and MPFR midpoint repair took
about 9.7 ms for 4,096 elements in both the scalar and serial batch runs.
On a general-range run with 65,536 elements per case, the median across
the original 71 cases was 1.0× for serial batching and 2.0× with four workers
relative to scalar broadcast. A caller-managed threaded scalar loop
also gave 2.0× on that run.

The expanded paths were measured against the public serial batch API
at revision `9b4a13cf` on the same CPU and Julia 1.13.3. These are
medians from 13 interleaved timings of 65,536 elements with one Julia
thread and no warmed heap allocations.

| Operations and input heads | Speedup over the previous batch API |
|:---|---:|
| `exp`, `exp10` on −100–100 | 3.2× |
| `expm1` on −100–100 | 2.6× |
| `hypot` and paired `normalize` on independent positive pairs from 0.25–8 | 4.2× and 2.0× |
| `inv` on −128–128 | 2.1× |
| `sin`, `cos`, `sincos` on −6.25–6.25 | 1.2× |
| `tan`, `cis` on −6.25–6.25 | 1.9× and 2.1× |

The compiler emitted vector loops for the converted exponentials,
positive-pair `hypot`, reciprocal, and the masked wide `tan` kernel on
this target. The wider circular pair and paired normalization also
benefited from the checked arithmetic when LLVM emitted scalar loops.
The `sin`, `cos`, and `sincos` fixtures on −100–100 ran near their
previous throughput because few lanes fell within one circle.

Run the driver from the package root. Its output includes the measured
range, storage, seed, Julia and CPU versions, CPU target, thread count,
revision, median and spread, allocations, and first-use time. For a
pre-change comparison, run the same driver with `--baseline` and the
older checkout as the active project.

```sh
julia --project -t4 perf/bench_simd_elementary.jl
SIMD_RANGE=general SIMD_SIZE=65536 julia --project -t4 perf/bench_simd_elementary.jl
SIMD_MIXTURE=0,0.01,0.1,0.5,1 SIMD_FILTER='^(sin|exp2|log)$' \
    julia --project perf/bench_simd_elementary.jl
```

Set `SIMD_CLUSTERED=1` for clustered mixtures, `SIMD_LOG_REGIMES=1` for
repeated table indices and direct/table mixtures, or `SIMD_RANGE=special`
for poles, exponential underflow, and MPFR midpoint repair. The driver
also supports comma-separated sizes, `SIMD_STORAGE=strided`, `narrow`, or
`alias`, alternative whole-block widths via `SIMD_BLOCK_SIZES`, and native
IR dumps into the directory given by `SIMD_LLVM`.
For dense calls, the driver prints lane eligibility counts for the
installed regimes. Eligible lanes can still use scalar code when a
whole block fails its checks.

The repository's `docs/vecbetter.md` records the phased rollout and the
numerical results for binary `atan`.

## Linear algebra

LAPACK covers only `Float32/64` and their complexes, so DoubleFloats
routes dense factorizations through pure-Julia generic implementations:

- `lu`, `qr`, `\`: LinearAlgebra's generic kernels.
- `eigen`, `eigvals`, `schur`, `hessenberg`: GenericSchur (QR iteration).
  DoubleFloats owns explicit `eigen`/`eigvals` methods
  (`src/math/linearalgebra/eigen.jl`) that pin this routing, detect
  hermitian input (tridiagonalization + symmetric QR: real eigenvalues,
  orthonormal vectors), and normalize output conventions to match the
  LAPACK route (real `Eigen` for a real spectrum, `(real, imag)` sorting,
  unit-norm vectors).
- `svd`: GenericLinearAlgebra.
- `sylvester`/`lyap` (`sylvester.jl`): Bartels–Stewart — Schur
  factorizations of both operands, triangular back-substitution,
  transform back.
- `lq`: the generic Householder QR of the adjoint, repackaged as an
  `LQ` factorization (`A = L·Q ⟺ A′ = Q_qr·R`), with the missing
  `LQPackedQ` materialization/multiplication kernels supplied for
  DoubleFloat element types.

## [Matrix functions](@id matrix-function-kernels)

See [Linear Algebra](linearalgebra.md#Functions-of-whole-matrices) for
function domains and a worked example. The dedicated implementations in
`src/math/linearalgebra/matfun.jl` can handle defective inputs. Structure checks apply
to the stored matrix. For a skipped entry, both limbs of each component
must be zero.

- **Exponential and trig/hyperbolic families.** The exponential uses
  scaling and squaring with a degree-34 Taylor polynomial evaluated by
  Paterson–Stockmeyer. For ordinary real `Double64` input with a
  positive one-norm up to `2^-7`, it uses degree 15. The circular and
  hyperbolic pairs share their powers and apply double-angle formulas.
  `cos` and `cosh` use the even polynomial alone.
- **Triangular products.** For eligible dense `Double64` and
  `ComplexDF64` triangles from size 64 and with input one-norm at most
  8, the polynomial and reconstruction products skip structurally zero
  entries. The products retain ascending accumulation order and check
  both limbs before using the packed arithmetic. Lower triangles are
  handled by transpose. `tan` and `tanh` also use triangular right
  division when the computed denominator is triangular and its
  distance from identity in the one-norm is at most 0.5.
- **Square root.** A triangular input uses the Björck–Hammarling
  recurrence on the original matrix. In the near-identity envelope
  `‖T - I‖₁ ≤ 0.625`, eligible triangles from size 96 use blocks of
  width 12. Rectangular updates pack directly from views, reusing
  per-call buffers, and the off-diagonal blocks are obtained by
  triangular Sylvester solves. The point recurrence handles small
  and excluded cases.
- **Logarithm.** The triangular route takes square roots until
  `‖T - I‖₁ ≤ 1/4` or the iteration cap is reached. It forms
  `G = (T - I)/(T + I)` by a triangular right solve and evaluates the
  atanh series. For eligible triangles, products use dense packed
  multiplication from size 24 and triangular packed multiplication
  from size 64. The inverse scaling uses the blocked square root
  whenever the current factor qualifies.
- **Schur reconstruction.** General `sqrt` and `log` use complex
  Schur factors. Eligible `ComplexDF64` factors from size 16 use a
  materialized adjoint in the packed reconstruction. The real-input
  result still goes through the usual imaginary-roundoff check.
- **Diagonal and symmetric routes.** Ordinary real `Double64`
  diagonal inputs use scalar diagonal evaluations for `exp`,
  `sqrt`, `log`, and the sine/cosine and hyperbolic sine/cosine
  families when the absolute diagonal heads are on `[2^-64, 8]`.
  The `sqrt` and `log` diagonal routes require positive entries.
  For ordinary real symmetric inputs from size 32 with
  one-norm at most 0.875, `exp` and the same paired and single-output
  trig and hyperbolic functions use the polynomial drivers.
  Other eligible symmetric/Hermitian inputs use eigendecomposition.
- **Fractional powers.** The usual `exp(p * log(A))` route can use
  the triangular optimizations in both stages. For ordinary
  nonsingular real `Double64` triangles in the near-identity
  envelope above, an exact exponent of one-half uses `sqrt`
  directly. The existing logarithm branch handles singular cases.

The general routes retain the type and branch conventions for
`sqrt`, `log`, and matrix powers. `cbrt`, `sinpi`/`cospi`, and the
matrix inverse circular and hyperbolic functions still use
eigen-diagonalization, which requires a diagonalizable argument.

### Matrix benchmarks

The table compares public calls against revision `58f7869c`. Timings
are medians of seven warmed runs on Julia 1.10.10 on an Intel Core
i9-14900K with native targeting, one Julia thread, and one BLAS
thread. Timings include structure checks, packing, and allocation.

| Operation and fixture | Before (ms) | After (ms) | Speedup |
|:---|---:|---:|---:|
| Real triangular `log`, 64×64 | 16.24 | 4.29 | 3.8× |
| Complex triangular `log`, 64×64 | 36.94 | 8.66 | 4.3× |
| General real `log`, 64×64 | 124.33 | 91.27 | 1.36× |
| Real triangular `sqrt`, 256×256 | 29.44 | 6.97 | 4.2× |
| Complex triangular `sqrt`, 256×256 | 65.33 | 18.29 | 3.6× |
| Real triangular `exp`, 256×256 | 91.09 | 38.88 | 2.3× |
| Real triangular `cos`, 256×256 | 66.07 | 22.30 | 3.0× |
| Real triangular `A^0.25`, 256×256 | 1,038.49 | 169.49 | 6.1× |
| Real triangular `A^0.5`, 256×256 | 1,039.39 | 7.83 | 133× |
| Real symmetric `exp`, 64×64 | 10.30 | 2.47 | 4.2× |
| Real symmetric `cos`, 64×64 | 10.24 | 1.46 | 7.0× |
| Real diagonal `exp`, 64×64 | 4.276 | 0.0096 | 445× |

Blocking uses additional temporary storage. The 256×256 complex root
allocated 5.6 MB in the blocked path versus 2.1 MB in the point path.
Packing directly from the block views reduced allocations from 52 MB
in the first blocked implementation. On the general logarithm fixture,
the complex Schur factorization still dominates the call.

Run the reproducible driver from the package root. It also reports
allocations and first-call time. Set `MAT_STAGES=1` for separate
factorization, product, solve, and reconstruction timings.

```sh
MAT_SIZE=64,256 MAT_FILTER='upper/(log|sqrt|exp|cos|halfpower)' \
    julia --project -t1 perf/bench_matrix_functions.jl
```

The repository's `docs/matbetter.md` records the rollout and the
admission checks for these algorithms.
