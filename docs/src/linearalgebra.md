# Linear Algebra

## Using

```julia
using DoubleFloats, GenericSVD, LinearAlgebra
```

## Vectors and Matrices

```julia
using DoubleFloats, GenericSVD, LinearAlgebra

n = 25
vector = rand(Double64, n)
matrix = reshape(rand(Double64,n*n),n,n)
```

## Operations

- `+`, `-`, `*`, `/`
- `rank`, `cond`, `norm`, `opnorm`, `det`, `tr`, `inv`, `pinv`
- `transpose`, `adjoint`
- `eigvals`, `eigvals!`, `svdvals`, `svdvals!`, `svd`

## Matrix Predicates

- `iszero`, `isone`, `isdiag`, 
- `issquare`, `issymmetric`, `ishermitian`, 
- `isposdef`, `isposdef!`
- `istril`, `istriu`

## Matrix Factorizations

- general: `lu`, `lu!`, `qr`, `qr!`
- square: `schur`, `schur!`, `hessenberg`, `hessenberg!`
- square+symmetric, Hermitian: `cholesky`, `cholesky!`
