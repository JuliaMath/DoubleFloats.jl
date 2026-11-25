# Representation and precision

## Choose a type

Each real type stores two floats of the same [underlying type](glossary.md#glossary-underlying-type). The number
of [significand bits](glossary.md#glossary-significand) reported by `precision(T)` describes the [nominal precision](glossary.md#glossary-precision). The significand is the part of the number that carries its
digits. The [exponent](glossary.md#glossary-exponent) sets their scale.

| Real type | Underlying pair | Nominal significand | Approximate decimal digits | Complex type |
|:----------|:----------------|--------------------:|---------------------------:|:-------------|
| [`Double64`](glossary.md#glossary-doublefloat) | two [`Float64`](glossary.md#glossary-binary-formats) | 106 bits | 32 | [`ComplexDF64`](glossary.md#glossary-complex) |
| [`Double32`](glossary.md#glossary-doublefloat) | two [`Float32`](glossary.md#glossary-binary-formats) | 48 bits | 14 | [`ComplexDF32`](glossary.md#glossary-complex) |
| [`Double16`](glossary.md#glossary-doublefloat) | two [`Float16`](glossary.md#glossary-binary-formats) | 22 bits | 6 | [`ComplexDF16`](glossary.md#glossary-complex) |

Start with `Double64` for more precision than `Float64`. A
`ComplexDF64` stores two `Double64` values, one for each component.
Use [`BigFloat`](glossary.md#glossary-bigfloat) when you need adjustable precision or a wider exponent
range. See [Choosing and checking precision](appropriate.md) for a
reference calculation.

## High and low components

For ordinary [normalized numbers](glossary.md#glossary-normalized-pair), the [high component](glossary.md#glossary-components) carries the leading
digits and the low component carries a correction. Arithmetic uses both
components. Adding them in the underlying type ordinarily rounds away
the correction.

Each type retains the exponent range of its underlying float. As a result
approaches the smallest representable magnitude, the low component can
become [subnormal](glossary.md#glossary-subnormal) or round to zero, reducing the effective precision.
The [Technical Guide](technicalguide.md) explains how the representation
affects the algorithms.

The [Accuracy Report](accuracy_report.md) uses a [relative working-precision
unit](glossary.md#glossary-working-unit) of `2^-104` for `Double64`. This is a scale for comparing measured
errors. The [spacing](glossary.md#glossary-eps) of a particular stored pair depends on its components.
