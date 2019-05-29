# Linear Algebra

## Using

```julia
using DoubleFloats, GenericSchur, GenericSVD, LinearAlgebra
```

## Vectors and Matrices

```julia
using DoubleFloats, GenericSchur, GenericSVD, LinearAlgebra

n = 25
vector = rand(Double64, n)
matrix = reshape(rand(Double64,n*n),n,n)


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

- general: `lu`, `lu!`, `qr`, `qr!`
- square: `schur`, `schur!`, `hessenberg`, `hessenberg!`
- square+symmetric, Hermitian: `cholesky`, `cholesky!`

## Functions of Matrices (diagonalizable & square only)

- `sqrt`, `cbrt`
- `matrix^power`
- `exp`, `log`
- `sin`, `cos`, `tan`, `csc`, `sec`, `cot`
- `asin`, `acos`, `atan`, `acsc`, `asec`, `acot`
- `sinh`, `cosh`, `tanh`, `csch`, `sech`, `coth`
- `asinh`, `acosh`, `atanh`, `acsch`, `asech`, `acoth`

- matrixfunction(function, matrix)


