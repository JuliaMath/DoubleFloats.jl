# Construct values

## Decimals, integers, and fractions

Use a [string literal](glossary.md#glossary-construction) for a decimal constant, the [constructor](glossary.md#glossary-construction) for text read at
runtime, and a [rational](glossary.md#glossary-rational) for an exact fraction. The result is represented as a
[DoubleFloat](glossary.md#glossary-doublefloat) in each case.

```@example construct
using DoubleFloats

from_literal = df64"0.2"
from_text = Double64("0.2")
from_fraction = Double64(1 // 5)
from_float = Double64(0.2)

@assert from_literal == from_text == from_fraction
@assert from_float != from_literal
nothing
```

Julia rounds an ordinary decimal literal to [`Float64`](glossary.md#glossary-binary-formats) before calling the
constructor. [Widening](glossary.md#glossary-widening) is appropriate for data that already consists of
`Float64` values. For smaller types, use `df32"…"` or `df16"…"`.

Small integers such as `Double64(2)` convert exactly. The integer
constructor converts through the underlying float, so large integers can
round before the [low component](glossary.md#glossary-components) is formed. Use a rational or a decimal
string when the integer has more bits than the underlying float can hold.

Create a [complex number](glossary.md#glossary-complex) from two values of the same precision, for
example `ComplexDF64(df64"0.2", df64"0.3")`. Julia's exact constants also
work directly, for example `Double64(pi)`.

## Working with two components

Use [`DoubleFloat(hi, lo)`](glossary.md#glossary-components) to represent the sum of two floats of the same
type in [normalized form](glossary.md#glossary-normalized-pair). [`HILO(x)`](glossary.md#glossary-components) retrieves the stored pair. The
two-component constructor `Double64(hi, lo)` with two `Float64` arguments
stores the components as supplied. It is useful when restoring an existing
pair whose components are already normalized.

```@example construct_pair
using DoubleFloats

x = DoubleFloat(1.0, 2.0^-60)
hi, lo = HILO(x)
@assert Double64(hi, lo) === x
nothing
```

See [Display and parse values](stringshowparse.md) to work with decimal
text, and [Representation and precision](characteristics.md) for the
meaning of the two components.
