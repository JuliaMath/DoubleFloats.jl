# Scalar operations

Use ordinary Julia operators and functions with DoubleFloats. The
following groups cover common operations. See [Special Functions](special.md)
for functions such as `erf` and [Linear Algebra](linearalgebra.md) for
operations on whole matrices.

| Task | Representative functions |
|:-----|:-------------------------|
| Arithmetic | `+`, `-`, `*`, `/`, `^`, `fma`, `muladd`, `inv`, `square`, `cube`, `sqrt`, `cbrt` |
| Rounding and integer parts | `round`, `floor`, `ceil`, `trunc`, `spread`, `intpart`, `fracpart` |
| Exponentials and logarithms | `exp`, `exp2`, `exp10`, `expm1`, `log`, `log2`, `log10`, `log1p` |
| Circular functions | `sin`, `cos`, `tan`, `sincos`, `cis`, `sinpi`, `cospi`, `tanpi`, `asin`, `acos`, `atan` |
| Hyperbolic functions | `sinh`, `cosh`, `tanh`, `asinh`, `acosh`, `atanh` |
| Magnitudes | `abs`, `abs2`, `hypot` |
| Predicates | `iszero`, `isone`, `isinteger`, `isfinite`, `isinf`, `isnan`, `issubnormal` |

The package also exports predicates such as `isnonzero`, `ispositive`,
`isnegative`, `isnonnegative`, `isnonpositive`, `isposinf`, `isneginf`,
and `isfractional`. To compare computed answers, see
[Choosing and checking precision](appropriate.md#Measure-the-error-you-care-about).

## Widen an arithmetic operation

For two inputs of the same underlying float type, `add2`, `sub2`,
`mul2`, and `div2` perform arithmetic and return the corresponding
DoubleFloat type. The infix equivalents are `⊕`, `⊖`, `⊗`, and `⊘`.
For example, `add2(1.0, 2.0^-60)` retains the small addend in the
low component. See [Representation and precision](characteristics.md).
