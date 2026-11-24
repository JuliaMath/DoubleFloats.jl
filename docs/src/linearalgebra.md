# Linear Algebra

Load `DoubleFloats` and `LinearAlgebra` for factorizations and matrix
operations. Use Julia's usual array syntax with an explicit element
type, such as `Double64[2 1; 1 3]` for a matrix or `Double64[1, 2]`
for a vector.

## Solve a system

```@example solve_system
using DoubleFloats, LinearAlgebra

A = Double64[2 1; 1 3]
b = Double64[1, 2]
x = A \ b
@assert norm(A * x - b, Inf) < df64"1e-30"
string.(x)
```

For several right-hand sides, reuse a factorization such as `F = lu(A)`
and solve each system with `F \ b`.

## Operations and factorizations

| Task | Representative functions |
|:-----|:-------------------------|
| Inspect structure | `isdiag`, `istriu`, `istril`, `issymmetric`, `ishermitian`, `isposdef` |
| Measure a matrix | `rank`, `cond`, `opnorm`, `det`, `logdet`, `logabsdet`, `tr` |
| Work with diagonals and transposes | `diag`, `diagind`, `transpose`, `adjoint` |
| Solve with `A \ b`, invert, or find a null space | `inv`, `pinv`, `nullspace` |
| General factorizations | `lu`, `qr`, `lq`, `svd` |
| Square matrix factorizations | `eigen`, `schur`, `hessenberg` |
| Structured factorizations | `cholesky` for positive-definite input, `bunchkaufman` for symmetric or Hermitian input |

`eigen` gives real eigenvalues and orthonormal eigenvectors for symmetric
or Hermitian input. For real input with an all-real spectrum, it gives
a real factorization. The default ordering sorts by real part and then
imaginary part.

Use `sylvester(A, B, C)` for `AX + XB + C = 0` and `lyap(A, C)`
for `AX + XA' + C = 0`. See the
[Technical Guide](technicalguide.md#Linear-algebra) for the implementation
and dependencies of the factorizations and equation solvers.

## Functions of whole matrices

For a square matrix, `exp(A)` is a matrix function. Use `exp.(A)`
for an elementwise operation. The same convention applies to `sqrt`,
`log`, and the trigonometric functions.

### Apply functions to a triangular matrix

The matrix below is a Jordan block. It has a repeated eigenvalue and
only one independent eigenvector, so it is *defective*. Writing it as
`A = I + N` with `N^2 = 0` gives exact formulas for the three
matrix functions. The checks use those formulas at Double64 precision.

```@example triangular_functions
using DoubleFloats, LinearAlgebra

A = Double64[1 1; 0 1]
N = A - I
tol = df64"1e-29"

E = exp(A)
L = log(A)
R = sqrt(A)

@assert opnorm(E - exp(one(Double64)) * A, 1) < tol
@assert opnorm(L - N, 1) < tol
@assert opnorm(R - (N / 2 + I), 1) < tol
@assert iszero(E[2, 1]) && exp.(A)[2, 1] == one(Double64)

println("Checked exp, log, and sqrt on a defective triangular matrix")
```

### Supported domains and branches

Dedicated matrix algorithms accept defective square inputs within the
function's domain.

- `exp`, `expm1`, `log`, `log1p`, `log2`, `log10`, and `sqrt`
- Fractional powers `A^p` for supported floating-point exponents
- `sin`, `cos`, `sincos`, `tan`, `cot`, `DoubleFloats.csc`, and
  `DoubleFloats.sec`
- `sinh`, `cosh`, `tanh`, `csch`, `sech`, and `coth`

For real input, `exp` returns a real matrix. `sqrt`, `log`, and
fractional powers can return complex matrices, for example when real
eigenvalues are negative. A singular matrix logarithm throws
`SingularException`. Fractional powers generally use `exp(p * log(A))`,
so the logarithm's domain matters there too. Matrix `expm1` and `log1p`
are computed as `exp(A) - I` and `log(A + I)`. Use the dotted forms
if you need the corresponding scalar algorithms applied to entries.

`cbrt`, `sinpi`, `cospi`, and the inverse circular and hyperbolic
families use `matrixfunction(f, A)`. This helper applies `f` to the
eigenvalues and transforms back using the eigenvectors. It requires a
square, diagonalizable matrix. Here the conditioning of the eigenvector
basis also affects accuracy.

### Structured inputs and performance

Dense storage with exact triangular structure can take specialized
routes. Triangular `sqrt` and `log` can skip Schur factorization.
Eligible larger triangles also use packed products for exponentials
and the circular and hyperbolic families. Eligible real diagonals use
direct scalar diagonal evaluations. See the
[Technical Guide](@ref matrix-function-kernels) for the ranges,
the exact half-power shortcut, and measured crossovers.
