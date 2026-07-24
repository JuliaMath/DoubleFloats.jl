# Adding New Functions

How to add a scalar function or a matrix function to DoubleFloats
safely, correctly, and robustly.  The recurring theme: double-double
accuracy is lost through *formulations*, not arithmetic — every addition
of nearly-opposite quantities, every fixed tolerance, and every unbounded
branch window is a place where 32 digits silently become 16.

## Part 1: scalar functions

### Step 0: choose the computation strategy

In descending order of preference:

1. **Native double-double** — series or recurrences evaluated in
   `DoubleFloat` arithmetic with double-double coefficients, plus exact
   argument reduction.  Fastest and most accurate; required when the
   function must preserve relative accuracy at a sensitive point
   (near a root or a fixed point), because no fixed-precision detour can.
2. **Composition of existing accurate functions** — e.g. the inverse
   hyperbolics are built from `log1p` and `sqrt`.  Correct *only* if the
   composition avoids cancellation (see Step 2).
3. **`Float128` route** — `DoubleFloat{T}(fn(Float128(x)))`, following
   the pattern of `erf`/`gamma`.  Simple and accurate to ~0.5 ulp, but:
   it cannot represent inputs finer than 113 bits (it fails for
   arguments like `1 + 1e-25` where the interesting part lives in the
   `lo` word), and it costs more than native code.  Good for functions
   whose sensitive regions do not coincide with sub-`Float64`-ulp input
   structure.

### Step 1: place and wire the code

- Implementation files live under `src/math/elementary/` (or
  `src/math/special/`), included from `src/DoubleFloats.jl`.
- Extend the appropriate `Base`/`SpecialFunctions` function: check that
  the name appears in the `import` lists at the top of
  `src/DoubleFloats.jl` (and in `export` if it is package-specific like
  `agm`).  A `function foo(...)` for a name that was *not* imported
  creates a new local function that users will never reach.
- Write for the generic signature
  `fn(x::DoubleFloat{T}) where {T<:IEEEFloat}`.  `Double32`/`Double16`
  variants of many functions are forwarded through `Double64` by
  `src/math/elementary/templated.jl`; add your function to its list if
  that treatment fits.

### Step 2: preserve relative accuracy at sensitive points

Identify where the function's value is small while its argument is not
degenerate — that is where naïve formulas collapse:

- **Never compute `log(1 + small)` via `1 + small`.**  The addition
  quantizes to the absolute floor `2⁻¹⁰⁴` and the logarithm inherits it
  as *relative* error that blows up as the argument shrinks.  Use
  `log1p` on an exactly-formed argument.
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

### Step 3: series and coefficients

- Coefficients must be double-double.  Generate `hi`/`lo` pairs from
  `BigFloat` at ≥ 256 bits and store them as `Double64(hi, lo)` tuple
  constants (see `inv_fact`, `inv_oddint`).
- Bound the truncation: with term ratio `r`, you need
  `n·log2(1/r) ≥ 107` plus margin.  State the bound in a comment.
- Series windows and branch guards must be **bounded on both sides**.
  A cautionary tale: a `cos` fix once guarded a small-angle Taylor
  kernel with `x >= π/2 - π/32` — with no upper bound, everything in
  `(π/2 + π/32, π)` also fell into a kernel valid only for `|r| ≤ π/32`,
  costing 17 digits over a large interval while all existing tests
  passed.  Write the window as `lo ≤ x ≤ hi`.

### Step 4: termination and special values

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

### Step 5: test against BigFloat, adversarially

Compare with a ≥ 256-bit `BigFloat` reference, measuring **relative**
error in units of `2⁻¹⁰⁴`:

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

Place tests in `test/` and wire the file into `test/runtests.jl`.

## Part 2: matrix functions

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
    (`sincos` from `exp(iA)`, `tanh` from `exp(±A)`, powers from
    `exp(p·log(A))`).

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
  `sin²+cos² = I` (they hold for *every* square matrix);
- **branch cases**: negative real eigenvalues (complex results),
  exactly singular `log`;
- **convention checks**: result eltype for real input; symmetric input
  giving (numerically) symmetric output — compare with a tolerance, not
  `ishermitian`, which tests exact equality;
- **scale**: a matrix with `‖A‖ ~ 100` to exercise deep
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
