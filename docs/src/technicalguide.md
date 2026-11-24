# Technical Guide

How DoubleFloats represents numbers and which algorithms sit behind the
public functions.  For guidance on extending the package, see
[Adding New Functions](addingfunctions.md).

## Representation: unevaluated sums

A `DoubleFloat{T}` holds two floats, `hi` and `lo`, whose *unevaluated
sum* is the represented value:

```
value = hi + lo,   with   |lo| ≤ ulp(hi)/2
```

`hi` is the value rounded to `T`; `lo` is the leading part of the
rounding error.  For `Double64` this yields a 106-bit significand
(2 × 53), about 32 decimal digits, with one ulp ≈ `2⁻¹⁰⁴` relative.

Two structural consequences matter throughout the package:

- **The exponent range is that of `T`.**  Overflow and underflow happen
  where `Float64` overflows and underflows.
- **Precision degrades near the bottom of the range.**  When
  `|value| < ~4e-292`, the `lo` word is subnormal and the effective
  precision tapers below 106 bits; below `~1e-308` only `Float64`
  precision remains.  This is a *representation* limit — visible, for
  example, in `exp(x)` for `x < -670` — and no algorithm returning a
  `Double64` can beat it.

## Error-free transformations

All arithmetic reduces to a handful of exact building blocks
(`src/math/errorfree.jl`):

- `two_sum(a, b)` / `two_hilo_sum(a, b)`: `hi + lo == a + b` exactly.
- `two_prod(a, b)`: `hi + lo == a * b` exactly, using `fma`.
- Division and square root use these plus one Newton-like correction
  (`src/math/ops/`), giving faithfully rounded (≤ 1 ulp) results.

A subtlety worth knowing: a **zero `lo` word does not mean a value is
exact**, and no fast path may skip the correction step because of it
(`inv` once did, and silently returned `Float64`-quality reciprocals for
inputs like `Double64(3.0)`).

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

## Matrix functions

`src/math/linearalgebra/matfun.jl`; all correct for defective matrices:

- **exp**: scaling-and-squaring; scale to `‖A‖₁ ≤ 1`, a 34-term Taylor
  approximant (truncation < 1/35! ≈ 1e-40) evaluated by
  Paterson–Stockmeyer (≈ 11 matrix products), then repeated squaring.
  Real input never leaves real arithmetic.
- **sqrt**: complex Schur + the Björck–Hammarling recurrence on the
  triangular factor; hermitian-PSD input shortcuts through `eigen`.
- **log**: complex Schur + inverse scaling-and-squaring — repeated
  triangular square roots until `‖T - I‖₁ ≤ ¼`, then the atanh series
  (re-using `inv_oddint`), then multiply by `2^s`.
- **trig/hyperbolic**: one shared-power series pair in `Y = B²` plus
  double-angle recurrences (`cos(2X) = 2cos²X - I`, `sin(2X) = 2 sin X cos X`
  — and the *same* formulas for cosh/sinh), entirely in the input's
  arithmetic, so real matrices never touch complex intermediates.
- **hermitian input** (exact `ishermitian`) short-circuits exp, trig, and
  hyperbolic functions through one symmetric eigen-decomposition — the
  orthonormal eigenvectors make that transform perfectly conditioned.
- **triangular input** skips the Schur factorization entirely for
  `sqrt`/`log` (the recurrences apply directly; `tril` maps to `triu`
  through the transpose identity).
- Real results that acquire ~`1e-32` imaginary roundoff dust from a
  complex intermediate are stripped back to real (with a tolerance
  guard), matching LAPACK-route behavior.

`cbrt`, `sinpi`/`cospi`, and matrix inverse-trig/hyperbolic functions
still use eigen-diagonalization (`matrixfunction`), which requires a
diagonalizable argument and loses accuracy in proportion to `cond(V)`.
