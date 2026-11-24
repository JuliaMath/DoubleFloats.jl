# Adding New Functions

Use this guide when extending scalar, vector, or matrix operations. For the
existing algorithms, see the [Technical Guide](technicalguide.md).
Choose a formulation that preserves the small quantities the result
depends on, including input corrections near roots and branch boundaries.

## Scalar functions

### Choose the computation strategy

1. **Native double-double arithmetic.** Use range reduction and a
   polynomial, series, or recurrence with coefficients precise enough
   for the error budget. Keep small offsets in their own variables when
   they govern relative accuracy.
2. **Compose existing functions.** The inverse hyperbolic functions
   use tools such as `log1p` and `sqrt`. Check the accuracy of the
   intermediate quantities in sensitive regions.
3. **Use a guarded wider scalar function.** The Double32 elementary
   paths use Float64 in bounded regions when converting both words
   preserves the exact input. Check that the result can be split back
   into a useful head and low word. Keep a path that retains the
   original representation for sensitive inputs and format limits.
4. **Convert through `Float128`.** The gamma and error functions use
   this strategy. Its 113-bit significand can round away a small
   correction when converting a pair with widely separated components.
   Test the errors from input conversion, function evaluation, and
   conversion back to the result type.

### Wire the method

- Implementation files live under `src/math/elementary/` (or
  `src/math/special/`), included from `src/DoubleFloats.jl`.
- When extending a `Base` or `SpecialFunctions` operation, import it
  in `src/DoubleFloats.jl` or qualify the method definition. Export a
  new package-specific function if callers should be able to use it
  unqualified after `using DoubleFloats`.
- Write for the generic signature
  `fn(x::DoubleFloat{T}) where {T<:IEEEFloat}`.  `Double32`/`Double16`
  variants of many functions are forwarded through `Double64` by
  `src/math/elementary/templated.jl`; add your function to its list if
  that treatment fits.

### Preserve relative accuracy at sensitive points

Identify where the function's value is small while its argument is not
degenerate — that is where naïve formulas collapse:

- Use `log1p(small)` to keep the small argument available to the
  logarithm. Forming `1 + small` first can round part or all of the
  correction away, which matters when the result is of order `small`.
- **Form differences exactly.**  `x - 1` is exact for
  `x ∈ [0.5, 2]` (Sterbenz); `(1-x)/x` has an exact numerator; algebraic
  rearrangement (`1 + 2/(x-1) == (x+1)/(x-1)`) can turn a cancelling
  formulation into an exact one.  The inverse hyperbolics in
  `archyptrig.jl` are worked examples.
- **Beware `inv` and squaring as information destroyers**: `1/x - 1`
  computed from `inv(x)` has already lost the digits that matter near
  `x = 1`; `square(x)` overflows for `|x| > ~1e154` even when the final
  result is modest (`asinh(2^520)` is ≈ 361).  Provide a large-argument
  branch (`√(x²+1) → x` for `x ≥ 4/eps(T)` is exact at working
  precision).

### Bound series and choose coefficients

- Generate coefficients at higher precision and store them as
  `hi`/`lo` pairs when they need double-word precision. See
  `_expm1_coeffs` in `explog.jl` for generated pairs. The tapered
  exponential kernels use scalar coefficients in higher-order terms
  where their contribution to the total error is small.
- Bound truncation over the whole reduced interval. For a series with
  tail term ratios bounded by `r < 1`, the first omitted term's
  magnitude divided by `1-r` bounds the omitted tail. Allow margin
  for evaluation and reconstruction errors.
- Series windows and branch guards must be **bounded on both sides**.
  A cautionary tale: a `cos` fix once guarded a small-angle Taylor
  kernel with `x >= π/2 - π/32` — with no upper bound, everything in
  `(π/2 + π/32, π)` also fell into a kernel valid only for `|r| ≤ π/32`,
  costing 17 digits over a large interval while all existing tests
  passed.  Write the window as `lo ≤ x ≤ hi`.

### Handle termination and special values

- Handle `NaN`, `±Inf`, `±0.0` (preserve the sign of zero), and domain
  errors (`DomainError` for out-of-domain reals, matching `Base`), and
  the exact endpoints, *before* the general path.
- **No fixed convergence tolerances derived from inputs.**  An
  iteration's achievable floor depends on the *result's* scale; a
  tolerance computed from the initial operands can be unattainable and
  loop forever (`agm` once did).  Prefer structural stopping rules: stop
  when the error measure stops decreasing.
- Comparisons used to exit loops must be NaN-safe: every comparison with
  NaN is false, so `while err > tol` exits on NaN but
  `stop when dnew >= d` does not.  Check `isnan` explicitly if an
  intermediate can overflow.
- Respect representation limits honestly: if the result's `lo` word
  would be subnormal (result magnitude below ~`4e-292` for `Double64`),
  full precision is impossible — do not chase it, and do not let an
  internal intermediate with that problem contaminate a result that *is*
  representable (rescale by exact powers of two instead; see `log`).

### Test against a higher-precision reference

Compare with a `BigFloat` reference computed at 256 bits or more.
For nonzero references, this snippet measures relative error in units
of `2^-104`. Use absolute error for an expected zero.

```julia
setprecision(BigFloat, 512)
ulps(got, want) = Float64(abs(BigFloat(got) - want) / abs(want) / big"2.0"^-104)
@test ulps(myfn(x), reffn(BigFloat(x))) < 2
```

Sample every region with its own tolerance:

- random points across the whole domain;
- dense probes at each *branch boundary* (both sides);
- the sensitive points: roots, fixed points, domain endpoints —
  including inputs whose structure lives below one `Float64` ulp, e.g.
  `Double64(1.0, 1e-25)`;
- extreme magnitudes: near `floatmax`, near `floatmin`, subnormals;
- special values: `NaN`, `±Inf`, `±0.0`, and exact `DomainError` edges.

Place tests in `test/` and wire the file into `test/runtests.jl`. The
[Accuracy Report](accuracy_report.md) describes the existing sampled checks.

## Vector functions

Extend the scalar operation first. `DoubleFloats.simdmap!(f, dest, x)`
and its two-input form already accept scalar callables, so an ordinary
elementwise function needs no batch registration. Add a native kernel
when a common input range admits a simpler evaluation that works across
several elements at once. The
[User Guide](userguide.md#Elementwise-operations-on-vectors) describes
the public calling and mutation rules.

### Register a bounded kernel

Put the specialized code beside the scalar implementation. Register
it with `_batch_kernel`, dispatching on the function, the destination
element type, and the element type of each input vector. The scalar
exponent accepted by `^` is passed by value, so its registration can
select a kernel for one exponent. The generic registration returns
`nothing`, which selects the scalar loop. Use the natural result type
for the kernel, such as `Tuple{Double64,Double64}` for `sincos` or
`ComplexDF64` for `cis` on finite real inputs.

The reciprocal registration in `src/math/ops/op_db_db.jl` shows the
pattern. `_BatchKernel` pairs an eligibility predicate with a per-element
evaluator. Shared helpers and the loop are in `src/math/elementary/simd.jl`.

```julia
@inline _batch_inv_range(x) = _batch_abs_bounded(x, 0x1p-256, 0x1p256)

_batch_kernel(::typeof(inv), ::Type{Double64}, ::Type{Double64}) =
    _BatchKernel(_batch_inv_range, _batch_inv)
```

Check both components of each input. The bounded-input helpers check
the high component against a chosen interval and bound the low
component by half the spacing in the corresponding exponent band.
Leave room for the low component at branch boundaries, and verify
that intermediates stay in range and divisors stay away from zero.
Reuse the scalar coefficients and error-free transforms where possible.
Keep the per-element evaluator type-stable and free of allocations,
side effects, exceptions, and floating-point reassociation. For native
two-word Double32 arithmetic, the batch predicate can admit normalized
pairs even when their sum would round in Float64. Keep the evaluator
inlined so the compiler can see the arithmetic across elements.

The driver checks axes and overlap before entering the dense route.
A native loop runs only after the whole block passes its predicate.
A rejected block normally runs scalar calls in index order, preserving
special values, destination conversion, and the writes that precede
an error. The driver also handles views, overlapping storage, and
custom vectors. Keep those rules in the shared driver.

Treat repair of isolated rejected elements as an optional optimization.
The existing `_BatchRepair` handles unary `Double64` inputs. It evaluates
eligible lanes and safe placeholder values in one loop, then overwrites
the placeholders with scalar results. Use it only where the rejected
lanes admitted by the driver's wider guard can be evaluated and assigned
without error. Ordinary block fallback is the starting point.

### Check results and measure the whole call

This example exercises both an eligible block and scalar fallback in
the same call. It compares stored components so small discrepancies and
signed zeros remain visible.

```@example adding_vector
using DoubleFloats

x = fill(Double64(1.125, -2.0^-58), 128)
x[end] = zero(Double64)
dest = similar(x)
reference = inv.(x)

@assert DoubleFloats.simdmap!(inv, dest, x) === dest
@assert all(isequal.(HILO.(dest), HILO.(reference)))
println("Checked reciprocal batch, including scalar fallback")
```

- Extend `test/simd_elementary.jl`. Test eligible inputs, mixed blocks,
  boundary points with both signs of the low component, and lengths
  around the 64-element minimum for the native route. Check the
  operation's special values, branches, output conversions, and
  exception order. Use the scalar result as the behavioral reference
  and a higher-precision calculation where the arithmetic changes.
- Measure warmed calls with reused destinations. The benchmark driver
  in `perf/bench_simd_elementary.jl` can compare against preallocated
  broadcast and check allocation and mixed-input costs. Use
  `SIMD_LLVM` to dump the native loop's LLVM and check for vector
  arithmetic. A SIMD annotation alone cannot establish that the
  compiler vectorized the loop.
- Evaluate threading separately. `_batch_thread_min` uses concrete
  argument types and defaults to no threaded execution for unlisted
  operations. Measure a size crossover before extending that allowlist
  and check the destination types admitted by `_batch_thread_output`.
  Exercise the new route with multiple Julia threads. A worker error
  can surface after other chunks have written.

Run the existing driver from the package root. This example compares
two batch sizes with eligible inputs and with scattered exclusions.

```sh
SIMD_FILTER=inv SIMD_SIZE=4096,65536 SIMD_MIXTURE=0,0.01 \
    julia --project -t4 perf/bench_simd_elementary.jl
```

Record published eligibility ranges and measured crossovers in the
[Technical Guide](@ref elementary-vector-kernels).

## Matrix functions

### Choose the algorithm class first

- **Eigen-diagonalization** (`matrixfunction(fn, m)`) is one line, but
  it *fails for defective matrices* and loses accuracy in proportion to
  `cond(V)` for nearly-defective ones — silently.  Acceptable for
  functions of practically-always-diagonalizable inputs, or as a
  starting point clearly documented as such.
- **Dense algorithms** are required for robustness:
  - series-friendly functions → scaling/squaring + Paterson–Stockmeyer
    (`_matexp` in `matfun.jl` is the template: scale to `‖A‖₁ ≤ 1`,
    evaluate, square back);
  - functions with a triangular recurrence → complex Schur, operate on
    `T`, transform back (`sqrt`, `log`);
  - anything expressible through `exp`/`log`/`sqrt` → compose
    when domains and branches agree. Matrix powers use
    `exp(p * log(A))` in the general case. The circular and
    hyperbolic families share polynomial and reconstruction code.

### Correctness rules

- **Respect type conventions.**  Real input whose mathematical result is
  real must return a real matrix.  Either stay in real arithmetic
  throughout (best: `exp`), take a hermitian shortcut when applicable,
  or strip imaginary roundoff dust with a tolerance guard
  (`_strip_imag_dust`) — never unconditionally `real.()`, which would
  corrupt genuinely complex results such as `sqrt` of a matrix with a
  negative eigenvalue.
- **Series bounds are norm bounds.**  The scalar truncation argument
  carries over with `|x|` replaced by `‖A‖`; scale first so the bound is
  small, and remember squaring steps amplify error — keep the
  approximant's truncation well below `2⁻¹⁰⁴`.
- **Triangular recurrences divide by `Tᵢᵢ + Tⱼⱼ`-type quantities**; an
  exactly-singular case should throw (`SingularException`), a
  nearly-singular one will honestly produce large entries — match what
  the `Float64` route does.
- Detect hermitian input (`ishermitian` is exact and O(n²)) and use the
  symmetric path: real eigenvalues, orthonormal vectors, better speed.

### Testing matrix functions

Random-matrix identity residuals alone are not enough; include:

- **defective matrices with closed forms**: `exp([1 1; 0 1]) = e·[1 1; 0 1]`,
  `sqrt([1 1; 0 1]) = [1 ½; 0 1]`, nilpotent `exp([0 1; 0 0]) = I + N`;
- **identity residuals**: `sqrt(A)² ≈ A`, `exp(log(A)) ≈ A`,
  `sin²+cos² = I`, using inputs in the functions' domains;
- **branch cases**: negative real eigenvalues (complex results),
  exactly singular `log`;
- **convention checks**: result eltype for real input; symmetric input
  giving (numerically) symmetric output — compare with a tolerance, not
  `ishermitian`, which tests exact equality;
- **Scale.** A matrix with `‖A‖ ~ 100` to exercise deep
  scaling/squaring.  Avoid identities with intrinsic cancellation
  amplification (`exp(A)·exp(-A) = I` fails at `e^{‖A‖}`-ish
  amplification for any correct implementation); compare against an
  eigen-reference on a symmetric matrix instead.

### Wiring

Dedicated implementations go in `src/math/linearalgebra/matfun.jl` (or a
sibling file included from `matrixfunction.jl`).  If a function moves
from the eigen route to a dedicated one, *remove it from the `@eval`
loop* in `matrixfunction.jl` — otherwise the loop's definition silently
overwrites yours (include order) or vice versa.
