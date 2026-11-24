# Representation and precision

## Choose a type

Each real type stores two floats of the same underlying type. The number
of significand bits reported by `precision(T)` describes the nominal
precision. The significand is the part of the number that carries its
digits. The exponent sets their scale.

| Real type | Underlying pair | Nominal significand | Approximate decimal digits | Complex type |
|:----------|:----------------|--------------------:|---------------------------:|:-------------|
| `Double64` | two `Float64` | 106 bits | 32 | `ComplexDF64` |
| `Double32` | two `Float32` | 48 bits | 14 | `ComplexDF32` |
| `Double16` | two `Float16` | 22 bits | 6 | `ComplexDF16` |

Start with `Double64` for more precision than `Float64`. A
`ComplexDF64` stores two `Double64` values, one for each component.
Use `BigFloat` when you need adjustable precision or a wider exponent
range. See [Choosing and checking precision](appropriate.md) for a
reference calculation.

## High and low components

For ordinary normalized numbers, the high component carries the leading
digits and the low component carries a correction. Arithmetic uses both
components. Adding them in the underlying type ordinarily rounds away
the correction.

Each type retains the exponent range of its underlying float. As a result
approaches the smallest representable magnitude, the low component can
become subnormal or round to zero, reducing the effective precision.
The [Technical Guide](technicalguide.md) explains how the representation
affects the algorithms.

The [Accuracy Report](accuracy_report.md) uses a relative working-precision
unit of `2^-104` for `Double64`. This is a scale for comparing measured
errors. The spacing of a particular stored pair depends on its components.
