# DoubleFloats.jl

### Math with 90+ accurate bits.

- __Five nested mathops on a DoubleF64 should exceed the accuracy of mathop(x::Float64)__

----

- 104:106 good bits: +, -, *
- 102:104 good bits: /, sqrt
-  99:102 good bits: exp, log, sin,  cos,  tan,  asin,  acos,  atan
-  96:99  good bits: sinh, cosh, tanh, asinh, acosh, atanh


[![][pkg-0.7-img]][pkg-0.7-url]  [![][travis-img]][travis-url]

----

## Documentation

- [Current](https://github.com/JuliaMath/DoubleFloats.jl/blob/master/docs/src/index.md) &mdash; **most recently tagged version of the documentation.**


## Installation

The package is registered in `METADATA.jl` and can be installed with `Pkg.add`.

```julia
julia> Pkg.add("DoubleFloats")
```

## Questions and Contributions

Usage questions can be posted on the [Julia Discourse forum][discourse-tag-url].  Use the topic `Numerics` (a "Discipline").

Contributions are very welcome, as are feature requests and suggestions. Please open an [issue][issues-url] if you encounter any problems. The [contributing page][contrib-url] has a few guidelines that should be followed when opening pull requests.

[contrib-url]: https://juliamath.github.io/DoubleFloats.jl/latest/man/contributing/
[discourse-tag-url]: https://discourse.julialang.org/tags/doublefloats
[gitter-url]: https://gitter.im/juliamath/users

[docs-current-img]: https://img.shields.io/badge/docs-latest-blue.svg
[docs-current-url]: https://juliamath.github.io/DoubleFloats.jl

[travis-img]: https://travis-ci.org/JuliaMath/DoubleFloats.jl.svg?branch=master
[travis-url]: https://travis-ci.org/JuliaMath/DoubleFloats.jl

[appveyor-img]: https://ci.appveyor.com/api/projects/status/xx7nimfpnl1r4gx0?svg=true
[appveyor-url]: https://ci.appveyor.com/project/JuliaMath/doublefloats-jl

[codecov-img]: https://codecov.io/gh/JuliaMath/DoubleFloats.jl/branch/master/graph/badge.svg
[codecov-url]: https://codecov.io/gh/JuliaMath/DoubleFloats.jl

[issues-url]: https://github.com/JuliaMath/DoubleFloats.jl/issues


[pkg-0.6-img]: http://pkg.julialang.org/badges/DoubleFloats_0.6.svg
[pkg-0.6-url]: http://pkg.julialang.org/?pkg=DoubleFloats&ver=0.6
[pkg-0.7-img]: http://pkg.julialang.org/badges/DoubleFloats_0.7.svg
[pkg-0.7-url]: http://pkg.julialang.org/?pkg=DoubleFloats&ver=0.7
