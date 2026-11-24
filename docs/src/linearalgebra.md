# Linear Algebra

## Using

```julia
using DoubleFloats, LinearAlgebra
```

## Vectors and Matrices

```julia
using DoubleFloats, LinearAlgebra

n = 25
vector = rand(Double64, n)
matrix = reshape(rand(Double64,n*n),n,n)
```

## Matrix Predicates

- `iszero`, `isone`, `isdiag` 
- `issquare`, `issymmetric`, `ishermitian` 
- `isposdef`, `isposdef!`
- `istril`, `istriu`

## Matrix Operations

- `+`, `-`, `*`, `/`
- `rank`, `cond`, `norm`, `opnorm`
- `diagind`, `diag`
- `transpose`, `adjoint`
- `inv`, `pinv`

## Matrix Functions

- `det`, `logdet`, `logabsdet`, `tr`
- `eigvals`, `eigvals!`, `eigvecs`, `eigen`
- `svdvals`, `svdvals!`, `svd`

## Matrix Factorizations

- general: `lu`, `lu!`, `qr`, `qr!`, `lq`
- square: `schur`, `schur!`, `hessenberg`, `hessenberg!`
- square+symmetric, Hermitian: `cholesky`, `cholesky!`, `bunchkaufman`

`eigen` for DoubleFloat matrices follows the LAPACK-route conventions:
symmetric/Hermitian input yields real eigenvalues and orthonormal vectors,
a real matrix with an all-real spectrum yields a real factorization, and
eigenvalues are sorted by `(real, imag)`.

## Matrix Equations

- `sylvester(A, B, C)` -- solves `AX + XB + C = 0`
- `lyap(A, C)` -- solves `AX + XA' + C = 0`

## Functions that support defective matrices

These functions use matrix algorithms that handle non-diagonalizable
square inputs within their domains.

- `exp`, `expm1`, `log`, `log1p`, `log2`, `log10`, `sqrt`
- `matrix^power`
- `sin`, `cos`, `sincos`, `tan`, `csc`, `sec`, `cot`
- `sinh`, `cosh`, `tanh`, `csch`, `sech`, `coth`

Dense `Double64` and `ComplexDF64` matrices can use accelerated
triangular paths when the stored entries have exact triangular
structure. Ordinary real `Double64` diagonal matrices have direct
paths for several functions. The algorithms and measured size ranges
are in the [Technical Guide](@ref matrix-function-kernels).

## Functions of Matrices (diagonalizable & square only)

These use eigen-diagonalization via `matrixfunction(function, matrix)`:

- `cbrt`, `sinpi`, `cospi`
- `asin`, `acos`, `atan`, `acsc`, `asec`, `acot`
- `asinh`, `acosh`, `atanh`, `acsch`, `asech`, `acoth`
