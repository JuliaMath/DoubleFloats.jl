# DoubleFloats.jl

DoubleFloats adds real and complex floating-point types for Julia. Start
with `Double64` when `Float64` loses too many digits in a calculation and
the values fit within the `Float64` exponent range. `Double64` represents
a number using two `Float64` components and provides about 32 decimal
digits of working precision in ordinary ranges.

## Install and try it

Use Julia 1.10 or later. Run this once in your Julia project.

```julia
using Pkg
Pkg.add("DoubleFloats")
```

Use a decimal string literal to create the number directly at the working
precision. Here `string` exposes the extra digits of the square root.

```@example first_value
using DoubleFloats

x = df64"2"
string(sqrt(x))
```

## Find the right guide

- [Construct values](construction.md) from decimal text, integers, fractions,
  or existing floating-point data. [Display and parse values](stringshowparse.md)
  explains how to inspect and exchange them.
- [Compute with scalars, vectors, and matrices](userguide.md) shows how to apply
  functions, reuse output arrays, and choose between `exp(A)` and `exp.(A)`.
- [Choose a precision and check your results](appropriate.md) explains how to
  measure error and includes a reference calculation with `BigFloat`.
- [Read the implementation and performance details](technicalguide.md) for
  algorithm choices, SIMD and matrix eligibility, and measured timings.

## Questions and contributions

Ask usage questions on [Julia Discourse](https://discourse.julialang.org/tags/doublefloats).
Report defects or propose features in the [issue tracker](https://github.com/JuliaMath/DoubleFloats.jl/issues).
See [Adding New Functions](addingfunctions.md) for contributor guidance.

## Acknowledgements

Many contributors have helped develop DoubleFloats. Claude Fable (High) was
applied for specific purposes with guidance, checking, and re-validation.
The logic for `exp` and `log` is adapted from MultiFloats.jl.
