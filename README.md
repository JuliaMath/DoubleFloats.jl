# DoubleFloats.jl

### Math with 85+ accurate bits.

----

[![Build Status](https://travis-ci.org/JuliaMath/DoubleFloats.jl.svg?branch=master)](https://travis-ci.org/JuliaMath/DoubleFloats.jl)
----

See [here](https://github.com/JuliaMath/DoubleFloats.jl/blob/master/test/function_accuracy.jl) for function specific absolute and relative errors over 0:1 and 1:2.

## Documentation

- [Current](https://github.com/JuliaMath/DoubleFloats.jl/blob/master/docs/src/index.md) &mdash; **most recently tagged version of the documentation.**


## Installation

The package is registered in `METADATA.jl` and can be installed with `Pkg.add`.

```julia
julia> Pkg.add("DoubleFloats")
```

## Proper Use

If your input values are Float64[Float32], map them to Double64[Double32] and proceed with your computation.  Then map the output values to Float64[Float32], and work with those values. Where throughput is important, this manner of us can be applied to particularly sensitive parts of your computation.

## Examples

```julia
julia> using DoubleFloats

julia> x = sqrt(Double64(2)) / sqrt(Double64(6));

julia> string(x)
"5.7735026918962576450914878050194151e-01"
julia> show(x)
5.7735026918962576450914878050194151e-01

julia> stringtyped(x)
"Double64(0.5773502691896257, 3.3450280739356326e-17)"
julia> showtyped(x)
Double64(0.5773502691896257, 3.3450280739356326e-17)

julia> 1 - x * inv(x)
0.0
```


```julia
julia> using DoubleFloats

julia> ϕ = Double32(MathConstants.golden)
1.61803398874989490
julia> phi = "1.61803398874989484820+"
julia> ϕ⁻¹ = inv(ϕ)
6.18033988749894902e-01

julia> ϕ == 1 + ϕ⁻¹
true
julia> ϕ === ϕ * ϕ⁻¹ + ϕ⁻¹
true
```


#### `MathConstants.golden` as `Float64` and `Double32`

|  typed value | computed value | ~abs(golden - computed) |
|:----------|:---------------|:-------------:|
| `MathConstants.golden` |  1.61803_39887_49894_84820_45868+ | 0.0 |
| `Float64(MathConstants.golden)`  | 1.61803_39887_49895 | 1.5e-16 |
| `Double32(MathConstants.golden)` |  1.61803_39887_49894_90 | 5.2e-17 |



## Performance

#### Double64 relative to BigFloat

| op  | speedup |
|:-----|---------:|
|  +   | 11x |
|  *   | 18x |
|  \   |  7x |
| trig | 3x-6x |

- results from testing with BenchmarkTools on one machine
- BigFloat precision was set to 106 bits, for fair comparison

## Questions and Contributions

Usage questions can be posted on the [Julia Discourse forum][discourse-tag-url].  Use the topic `Numerics` (a "Discipline") and a put the package name, DoubleFloats, in your question ("topic").

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
