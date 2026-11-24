# Display and parse values

## Inspect a value

Compact display, as used for many array elements, shows the high
component. To see more decimal digits, use `string(x)` or print those
digits with `showall(x)`. Use `stringtyped(x)` or `showtyped(x)` to
inspect the type and both components.

```@example display_value
using DoubleFloats

x = sqrt(Double64(2))
println(string(x))
showtyped(x)
```

These helpers also accept the complex counterparts. For exact access to
the stored components of a real value, use `HILO(x)`. For a complex value,
apply `HILO` to its real and imaginary parts separately.

## Read numeric text

Use `Double64(text)` or `parse(Double64, text)` for a decimal number.
Use `ComplexDF64(text)` for complex numeric text. The text passed to
`parse` is a numeric literal. `stringtyped` instead returns Julia
constructor syntax for inspection.

```@example parse_value
using DoubleFloats

x = parse(Double64, "0.125")
z = ComplexDF64("0.125 - 0.25im")
@assert real(z) == x
@assert imag(z) == df64"-0.25"
nothing
```

Decimal formatting is useful for human-readable output. When every stored
component matters, keep the typed value or save the two components using a
format that preserves each underlying float. See
[Construct values](construction.md#Working-with-two-components).
