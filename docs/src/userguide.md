# User Guide

This guide covers everyday use of DoubleFloats: creating values, what
accuracy to expect, and how the elementary, special, and matrix functions
behave.  For how things work internally, see the Technical Guide.

## The types

| type | built from | significand | decimal digits | exponent range |
|:-----|:-----------|------------:|---------------:|:---------------|
| `Double64` | two `Float64` | 106 bits | ~32 | same as `Float64` |
| `Double32` | two `Float32` | 48 bits  | ~14 | same as `Float32` |
| `Double16` | two `Float16` | 22 bits  | ~6  | same as `Float16` |

`ComplexDF64`, `ComplexDF32`, `ComplexDF16` are the complex counterparts.

`Double64` is the recommended type.  It is faster and more precise than
`Double32`/`Double16` (which mainly exist for completeness), and much
faster than `BigFloat` at comparable precision in typical workloads.
The values are immutable bitstypes, and ordinary scalar arithmetic
does not allocate.

## Constructing values

```julia
using DoubleFloats

Double64(2)          # exact: integers convert exactly
Double64(2) / 10     # 0.2 to full Double64 precision
df64"0.2"            # string literal: 0.2 to full Double64 precision
Double64(0.2)        # NOT 1/5: 0.2 is rounded to Float64 *first*
```

The last line is the most common pitfall: a decimal literal like `0.2`
is already a `Float64` approximation before `Double64` sees it.  Use
integer ratios or the string macros (`df64"..."`, `df32"..."`, `df16"..."`)
whenever a decimal constant must be exact to full precision.

`showtyped`, `stringtyped`, and `parse` round-trip values exactly:

```julia
julia> x = sqrt(Double64(2));
julia> showtyped(x)
Double64(1.4142135623730951, -9.667293313452913e-17)
julia> parse(Double64, stringtyped(x)) === x
true
```

## What accuracy to expect

One unit in the last place (ulp) of `Double64` is about `2⁻¹⁰⁴ ≈ 4.9e-32`
relative. The elementary functions generally deliver working-precision
accuracy. In the [Accuracy Report](accuracy_report.md), the sampled
maximum error varies by function and input range. For example, the
sampled worst case for `exp` on `(-100, 100)` is about 3.3 ulps.

Boundary behavior worth knowing:

- For `Double64`, `exp(x)` overflows near `x ≈ 709.78` and rounds
  to zero near `x ≈ -745.13`. As the result approaches zero its low
  limb eventually runs out of representable bits. Subnormal results
  from `exp`, `exp2`, and `exp10` on `Double64` and `Double32`
  round to the nearest value on the underlying float's subnormal grid.
  For example, `exp2(Double64(-1075.0))` rounds to zero, while
  `exp2(Double64(-1075.0, 1e-30))` returns the smallest positive
  `Float64` subnormal as a `Double64`.
- A finite positive logarithm argument can have a tiny low limb, even
  when its high limb is far from zero. Mantissa normalization accounts
  for low limbs that would become subnormal during scaling.
- Scalar `cbrt` returns the same double-word type as its argument.
  `Double64` cube roots retain working precision at extreme magnitudes
  through scaling before refinement.
- `sinh`/`cosh` stay finite through `x ≈ 710.47`.
- Relative accuracy near the zeros of `sin`/`cos` is limited by the
  condition of the function itself; absolute accuracy stays at the
  `2⁻¹⁰⁴` level.

## Elementary and special functions

All the familiar functions are available; see Capabilities for the full
list.  Special functions include `erf`, `erfc`, `gamma`, `loggamma`,
Bessel functions `besselj0/j1/y0/y1`, `besselj(n, x)`, `bessely(n, x)`,
the arithmetic-geometric mean `agm(a, b)` / `agm1(x)`, and the complete
elliptic integral `ellipk(m)` (accurate over the whole domain `0 ≤ m < 1`,
including arbitrarily close to `m = 1`).

`erf`, `erfc`, `gamma`, and the Bessel functions are computed through
`Float128` (113-bit) arithmetic, which caps them at roughly half a
`Double64` ulp — in practice, full accuracy.

## Linear algebra

```julia
using DoubleFloats, LinearAlgebra
```

Everything routine works with `Double64`/`ComplexDF64` matrices:
`lu`, `qr` (plain and pivoted), `lq`, `cholesky`, `svd`, `eigen`,
`schur`, `hessenberg`, `bunchkaufman`, `\` (square and least squares),
`det`, `inv`, `pinv`, `nullspace`, `rank`, `cond`, `opnorm`,
`sylvester`, and `lyap`.

`eigen` follows the same conventions as the LAPACK route for `Float64`:
symmetric/Hermitian input yields real eigenvalues and orthonormal
vectors; a real matrix whose spectrum is entirely real yields a real
factorization; eigenvalues are sorted by `(real, imag)`.

## Functions of matrices

`exp`, `log`, `sqrt`, and the trigonometric/hyperbolic families work on
**every** square matrix, including defective (non-diagonalizable) ones,
using dense Schur-based and scaling-and-squaring algorithms:

```julia
julia> exp(Double64[1 1; 0 1])     # defective; diagonalization would fail
2×2 Matrix{Double64}:
 2.71828  2.71828
 0.0      2.71828
```

Real matrices give real results whenever the mathematical result is real
(e.g. `exp` of any real matrix, `sqrt`/`log` of matrices without negative
real eigenvalues).  A negative real eigenvalue makes `sqrt`/`log`
genuinely complex, and the result type reflects that.

The remaining families (`cbrt`, `sinpi`/`cospi`, and the inverse
trigonometric/hyperbolic functions of matrices) use eigen-diagonalization
and require a diagonalizable argument.

## Performance

See the [Benchmark Report](benchmark_report.md) for representative
timings. Exponential inputs guaranteed to round to zero skip the
polynomial. A subnormal result close enough to a rounding midpoint can
require a higher-precision fallback, which takes longer and allocates.
Near-cancelling `Double64` `fma` and `muladd` calls also do more
work than ordinary calls, using an allocation-free refinement.
