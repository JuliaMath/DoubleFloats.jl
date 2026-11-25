# Choosing and checking precision

## Decide where to widen

Convert existing inputs before a numerically sensitive calculation.
If the input is decimal text, read it directly into the chosen type.
[Higher-precision arithmetic](glossary.md#glossary-precision) can reduce rounding during the calculation.
Any rounding in the original inputs is already part of the problem you
are solving.

Keep values at the working precision through subsequent sensitive steps.
Convert back to [`Float64`](glossary.md#glossary-binary-formats) at an interface that needs it, such as a storage
format or downstream routine. For a large workload, measure the accuracy
and cost of [widening](glossary.md#glossary-widening) the part where it makes a difference.

## Measure the error you care about

[Absolute error](glossary.md#glossary-absolute-error) is the [magnitude](glossary.md#glossary-magnitude) of the difference from a [reference result](glossary.md#glossary-reference-result). [Relative error](glossary.md#glossary-relative-error)
measures that distance as a fraction of the reference magnitude. Use an
[absolute tolerance](glossary.md#glossary-tolerance) near an expected zero, and a [relative tolerance](glossary.md#glossary-tolerance) when
the scale of a nonzero answer matters. For a [linear system](glossary.md#glossary-linear-system), a small
[residual](glossary.md#glossary-residual) [`A*x - b`](glossary.md#glossary-linear-system) shows that the computed solution nearly satisfies the
equations. How close it is to the desired solution also depends on the
problem’s [conditioning](glossary.md#glossary-conditioning), meaning its sensitivity to changes in the data.

For two same-type DoubleFloats, scalar [`isapprox`](glossary.md#glossary-tolerance) derives its default
relative tolerance from the high components. It also accepts identical
high components and uses an absolute floor of `1e-32`. To validate the
low component or apply a tighter absolute tolerance, measure the
difference directly, as in the example below.

## Keep a small correction

Here the quantity of interest is [`log(1 + δ)`](glossary.md#glossary-delta). At this scale `Float64`
rounds `1 + δ` to one. [`log1p`](glossary.md#glossary-offset-functions) computes the quantity directly, and a
higher-precision reference lets us check the resulting error. The
reference starts from the same decimal text as the working value.
Comparing the two input representations at high precision isolates
[input rounding](glossary.md#glossary-rounding-error). The relative error of the final result includes both
input rounding and arithmetic error.

```@example check_precision
using DoubleFloats

text = "1e-20"
δ = Double64(text)
result = log1p(δ)

input_errors, relative_error = setprecision(BigFloat, 256) do
    exact_input = parse(BigFloat, text)
    reference = log1p(exact_input)
    input_errors = abs.((BigFloat(parse(Float64, text)) - exact_input,
                         BigFloat(δ) - exact_input))
    input_errors, abs(BigFloat(result) - reference) / abs(reference)
end

@assert log(1 + parse(Float64, text)) == 0.0
@assert input_errors[2] < input_errors[1]
@assert relative_error < big"1e-29"
println("Relative error: ", Float64(relative_error))
```

The [Accuracy Report](accuracy_report.md) gives sampled errors and matrix
residuals for a range of functions. The input ranges and metrics matter
when comparing those results with your computation.
