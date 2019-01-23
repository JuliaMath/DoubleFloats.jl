# DoubleFloats.jl

### Math with 85+ accurate bits.

----

[![Build Status](https://travis-ci.org/JuliaMath/DoubleFloats.jl.svg?branch=master)](https://travis-ci.org/JuliaMath/DoubleFloats.jl)&nbsp;&nbsp;&nbsp;[![Docs](https://img.shields.io/badge/docs-stable-blue.svg)](http://jeffreysarnoff.github.io/DoubleFloats.jl/latest/)

----

## Accuracy


results for f(x), x in 0..1
 

| function |   abserr   |   relerr   |
|:--------:|:----------:|:----------:|
|   exp    |  1.0e-31   |   1.0e-31  |
|   log    |  1.0e-31   |   1.0e-31  |
|          |            |            |
|   sin    |  1.0e-31   |   1.0e-31  |
|   cos    |  1.0e-31   |   1.0e-31  |
|   tan    |  1.0e-31   |   1.0e-31  |
|          |            |            |
|  asin    |  1.0e-30   |   1.0e-30  |
|  acos    |  1.0e-30   |   1.0e-29  |
|  atan    |  1.0e-31   |   1.0e-30  |
|          |            |            |
|          |            |            |
|   sinh   |  1.0e-31   |   1.0e-29  |
|   cosh   |  1.0e-31   |   1.0e-31  |
|   tanh   |  1.0e-31   |   1.0e-29  |
|          |            |            |
|  asinh   |  1.0e-31   |   1.0e-29  |
|  atanh   |  1.0e-31   |   1.0e-30  |


results for f(x), x in 1..2
 

| function |   abserr   |   relerr   |   notes   |
|:--------:|:----------:|:----------:|:---------:|
|   exp    |  1.0e-30   |   1.0e-31  | |
|   log    |  1.0e-31   |   1.0e-31  | |
|          |            |            | |
|   sin    |  1.0e-31   |   1.0e-31  | |
|   cos    |  1.0e-31   |   1.0e-28  | |
|   tan    |  1.0e-24   |   1.0e-28  | near asymptote |
|          |            |            | |
|  asin    |  1.0e-30   |   1.0e-30  | |
|  acos    |  1.0e-30   |   1.0e-29  | |
|  atan    |  1.0e-31   |   1.0e-30  | |
|          |            |            | |
|          |            |            | |
|   sinh   |  1.0e-30   |   1.0e-31  | |
|   cosh   |  1.0e-30   |   1.0e-31  | |
|   tanh   |  1.0e-31   |   1.0e-31  | |
|          |            |            | |
|  asinh   |  1.0e-31   |   1.0e-31  | |


## Installation

```julia
pkg> add DoubleFloats
```
or
```julia
julia> using Pkg
julia> Pkg.add("DoubleFloats")
```

## Examples

#### Double64, Double32, Double16
```julia
julia> using DoubleFloats

julia> dbl64 = sqrt(Double64(2)); 1 - dbl64 * inv(dbl64)
0.0
julia> dbl32 = sqrt(Double32(2)); 1 - dbl32 * inv(dbl32)
0.0
julia> dbl16 = sqrt(Double16(2)); 1 - dbl16 * inv(dbl16)
0.0

julia> typeof(ans) === Double16
true
```
note: floating-point constants must be used with care,
they are evaluated as Float64 values before additional processing
```julia
julia> Double64(0.2)
2.0000000000000001110223024625156540e-01

julia> Double64(2)/10
1.9999999999999999999999999999999937e-01

julia> d64"0.2"
1.9999999999999999999999999999999937e-01
```
#### show, string, parse
```julia
julia> using DoubleFloats

julia> x = sqrt(Double64(2)) / sqrt(Double64(6))
0.5773502691896257

julia> string(x)
"5.7735026918962576450914878050194151e-01"

julia> show(IOContext(Base.stdout,:compact=>false),x)
5.7735026918962576450914878050194151e-01

julia> showtyped(x)
Double64(0.5773502691896257, 3.3450280739356326e-17)

julia> showtyped(parse(Double64, stringtyped(x)))
Double64(0.5773502691896257, 3.3450280739356326e-17)

julia> Meta.parse(stringtyped(x))
:(Double64(0.5773502691896257, 3.3450280739356326e-17))
```

#### golden ratio
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

## Good Ways To Use This

In addition to simply `using DoubleFloats` and going from there, these two suggestions are easily managed
and will go a long way in increasing the robustness of the work and reliability in the computational results.   

If your input values are Float64s, map them to Double64s and proceed with your computation.  Then unmap your output values as Float64s, do additional work using those Float64s. With Float32 inputs, used Double32s similarly. Where throughput is important, and your algorithms are well-understood, this approach be used with the numerically sensitive parts of your computation only.  If you are doing that, be careful to map the inputs to those parts and unmap the outputs from those parts just as described above.

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
