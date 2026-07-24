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
faster than `BigFloat` at comparable precision because values are
immutable bitstypes with no per-operation allocation.

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
relative.  The elementary functions (`exp`, `log`, `sin`, `cos`, `tan`,
inverses, hyperbolics and their inverses) are accurate to about 1 ulp
across their domains, including the traditionally difficult regions:
`log` near 1, `asinh`/`atanh` near 0, `acosh` near 1, trigonometric
argument reduction near multiples of π/2.  Measured results are in the
[Accuracy Report](accuracy_report.md).

Boundary behavior worth knowing:

- `exp(x)` overflows to `Inf` at `x ≈ 709.78` and underflows to `0`
  near `x ≈ -745.2`, like `Float64`.  For `x` below about `-670` the
  result's low word falls under `Float64`'s subnormal floor, so fewer
  than 32 digits are *representable* — any library returning `Double64`
  has this limit.
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

See the [Benchmark Report](benchmark_report.md).  As rough guidance:
scalar arithmetic is a small multiple of `Float64` cost, elementary
functions are 50–250x `Float64` (and several times faster than
`BigFloat`), and dense linear algebra pays an additional factor for
running pure-Julia generic kernels instead of BLAS/LAPACK.
