# Scalar operations

Use ordinary Julia operators and functions with DoubleFloats. The
following groups cover common operations. See [Special Functions](special.md)
for functions such as `erf` and [Linear Algebra](linearalgebra.md) for
operations on whole matrices.

| Task | Representative functions |
|:-----|:-------------------------|
| Arithmetic | `+`, `-`, `*`, `/`, `^`, [`fma`](glossary.md#glossary-fma), `muladd`, `inv`, `square`, `cube`, `sqrt`, `cbrt` |
| Rounding and integer parts | [`round`](glossary.md#glossary-rounding), `floor`, `ceil`, `trunc`, `spread`, `intpart`, `fracpart` |
| Exponentials and logarithms | [`exp`](glossary.md#glossary-exp-log), `exp2`, `exp10`, [`expm1`](glossary.md#glossary-offset-functions), `log`, `log2`, `log10`, [`log1p`](glossary.md#glossary-offset-functions) |
| [Circular functions](glossary.md#glossary-trigonometric) | `sin`, `cos`, `tan`, [`sincos`](glossary.md#glossary-paired-trig), `cis`, `sinpi`, `cospi`, `tanpi`, `asin`, `acos`, `atan` |
| [Hyperbolic functions](glossary.md#glossary-hyperbolic) | `sinh`, `cosh`, `tanh`, `asinh`, `acosh`, `atanh` |
| Magnitudes | `abs`, `abs2`, [`hypot`](glossary.md#glossary-paired-normalization) |
| [Predicates](glossary.md#glossary-predicates) | `iszero`, `isone`, `isinteger`, `isfinite`, `isinf`, `isnan`, `issubnormal` |

The package also exports predicates such as `isnonzero`, `ispositive`,
`isnegative`, `isnonnegative`, `isnonpositive`, `isposinf`, `isneginf`,
and `isfractional`. To compare computed answers, see
[Choosing and checking precision](appropriate.md#Measure-the-error-you-care-about).

## Widen an arithmetic operation

For two inputs of the same underlying float type, [`add2`](glossary.md#glossary-widened-operators), `sub2`,
`mul2`, and `div2` perform arithmetic and return the corresponding
DoubleFloat type. The infix equivalents are [`⊕`](glossary.md#glossary-widened-operators), [`⊖`](glossary.md#glossary-widened-operators), [`⊗`](glossary.md#glossary-widened-operators), and [`⊘`](glossary.md#glossary-widened-operators).
For example, `add2(1.0, 2.0^-60)` retains the small addend in the
low component. See [Representation and precision](characteristics.md).
