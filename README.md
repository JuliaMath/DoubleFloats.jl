# DoubleFloats.jl

[![Stable documentation](https://img.shields.io/badge/docs-stable-blue.svg)](https://juliamath.github.io/DoubleFloats.jl/stable/)
[![Development documentation](https://img.shields.io/badge/docs-dev-blue.svg)](https://juliamath.github.io/DoubleFloats.jl/dev/)
[![Coverage](https://codecov.io/gh/JuliaMath/DoubleFloats.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/JuliaMath/DoubleFloats.jl)

DoubleFloats provides extended-precision real and complex types for Julia.
`Double64` uses two `Float64` components to provide about 32 decimal digits
of working precision in ordinary ranges, with the exponent range of
`Float64`. The package also provides `Double32`, `Double16`, and their
complex counterparts.

## Installation

```julia
using Pkg
Pkg.add("DoubleFloats")
```

## First calculation

```julia
using DoubleFloats

rate = df64"0.2"            # read decimal text directly as Double64
growth = exp(rate)
println(string(growth))
```

Use `Double64(x)` to widen an existing `Float64` input. Writing
`Double64(0.2)` widens the binary approximation Julia already made from the
literal `0.2`. Use the string literal above when you intend the decimal value.

## Documentation

- [User Guide](https://juliamath.github.io/DoubleFloats.jl/dev/userguide/) for
  scalar calculations, vector batches, and matrix functions.
- [Choosing and checking precision](https://juliamath.github.io/DoubleFloats.jl/dev/appropriate/)
  for a worked accuracy check with a higher-precision reference.
- [Accuracy measurements](https://juliamath.github.io/DoubleFloats.jl/dev/accuracy_report/)
  and [benchmark results](https://juliamath.github.io/DoubleFloats.jl/dev/benchmark_report/)
  for the tested functions and input ranges.

## Questions and contributions

Ask usage questions on [Julia Discourse](https://discourse.julialang.org/tags/doublefloats).
Feature requests, suggestions, and bug reports are welcome in the
[issue tracker](https://github.com/JuliaMath/DoubleFloats.jl/issues).
