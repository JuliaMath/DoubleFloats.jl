# Linear Algebra

Load `DoubleFloats` and `LinearAlgebra` for [factorizations](glossary.md#glossary-factorization) and matrix
operations. Use Julia's usual array syntax with an explicit element
type, such as `Double64[2 1; 1 3]` for a matrix or `Double64[1, 2]`
for a vector.

## Solve a system

In this example, [`A`](glossary.md#glossary-linear-system), [`x`](glossary.md#glossary-linear-system) and [`b`](glossary.md#glossary-linear-system) are the coefficient matrix,
solution, and right-hand side. The check measures the [residual](glossary.md#glossary-residual)
with the infinity [norm](glossary.md#glossary-norm).

```@example solve_system
using DoubleFloats, LinearAlgebra

A = Double64[2 1; 1 3]
b = Double64[1, 2]
x = A \ b
@assert norm(A * x - b, Inf) < df64"1e-30"
string.(x)
```

For several right-hand sides, reuse a factorization such as [`F = lu(A)`](glossary.md#glossary-factorization)
and solve each system with [`F \ b`](glossary.md#glossary-linear-system).

## Operations and factorizations

| Task | Representative functions |
|:-----|:-------------------------|
| Inspect structure | `isdiag`, `istriu`, `istril`, `issymmetric`, `ishermitian`, `isposdef` |
| Measure a matrix | `rank`, `cond`, `opnorm`, `det`, `logdet`, `logabsdet`, `tr` |
| Work with diagonals and transposes | `diag`, `diagind`, `transpose`, [`adjoint`](glossary.md#glossary-adjoint) |
| Solve with `A \ b`, invert, or find a [null space](glossary.md#glossary-matrix-invariants) | `inv`, `pinv`, `nullspace` |
| General factorizations | `lu`, `qr`, `lq`, [`svd`](glossary.md#glossary-svd) |
| Square matrix factorizations | `eigen`, [`schur`](glossary.md#glossary-schur), [`hessenberg`](glossary.md#glossary-schur) |
| Structured factorizations | [`cholesky`](glossary.md#glossary-structured-factorization) for [positive-definite](glossary.md#glossary-positive-definite) input, `bunchkaufman` for symmetric or [Hermitian](glossary.md#glossary-adjoint) input |

`eigen` gives real [eigenvalues](glossary.md#glossary-eigen) and [orthonormal](glossary.md#glossary-orthonormal) [eigenvectors](glossary.md#glossary-eigen) for symmetric
or Hermitian input. For real input with an [all-real spectrum](glossary.md#glossary-eigen), it gives
a real factorization. The default ordering sorts by real part and then
imaginary part.

Use [`sylvester(A, B, C)`](glossary.md#glossary-sylvester) for [`AX + XB + C = 0`](glossary.md#glossary-sylvester) and [`lyap(A, C)`](glossary.md#glossary-sylvester)
for `AX + XA' + C = 0`. See the
[Technical Guide](technicalguide.md#Linear-algebra) for the implementation
and dependencies of the factorizations and equation solvers.

## Functions of whole matrices

For a square matrix, `exp(A)` is a [matrix function](glossary.md#glossary-matrix-function). Use [`exp.(A)`](glossary.md#glossary-broadcast)
for an elementwise operation. The same convention applies to `sqrt`,
`log`, and the trigonometric functions.

### Apply functions to a triangular matrix

The matrix below is a [Jordan block](glossary.md#glossary-jordan). It has a repeated eigenvalue and
only one independent eigenvector, so it is *[defective](glossary.md#glossary-jordan)*. Writing it as
[`A = I + N`](glossary.md#glossary-identity-matrix) with [`N^2 = 0`](glossary.md#glossary-identity-matrix) gives exact formulas for the three
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

The [matrix exponential](glossary.md#glossary-matrix-function) of a real matrix is real. `sqrt`, `log`, and
fractional powers can return complex matrices, for example when real
eigenvalues are negative. A singular matrix logarithm throws
[`SingularException`](glossary.md#glossary-singular). Fractional powers generally use `exp(p * log(A))`,
so the logarithm's domain matters there too. Matrix `expm1` and `log1p`
are computed as `exp(A) - I` and `log(A + I)`. Use the dotted forms
if you need the corresponding scalar algorithms applied to entries.

`cbrt`, `sinpi`, `cospi`, and the inverse circular and hyperbolic
families use `matrixfunction(f, A)`. This helper applies `f` to the
eigenvalues and transforms back using the eigenvectors. It requires a
square, [diagonalizable](glossary.md#glossary-jordan) matrix. Here the [conditioning](glossary.md#glossary-conditioning) of the eigenvector
basis also affects accuracy.

### Structured inputs and performance

Dense storage with exact [triangular structure](glossary.md#glossary-triangular) can take specialized
routes. Triangular `sqrt` and `log` can skip Schur factorization.
Eligible larger triangles also use packed products for exponentials
and the circular and hyperbolic families. Eligible real diagonals use
direct scalar diagonal evaluations. See the
[Technical Guide](@ref matrix-function-kernels) for the ranges,
the exact half-power shortcut, and measured crossovers.
