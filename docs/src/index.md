# DoubleFloats.jl

### Math with 85+ accurate bits.
#### Extended precision float and complex types

- N.B. `Double64` is the most performant type <sup>[β](#involvement)</sup>

----

## Installation

```julia
pkg> add DoubleFloats
```
or
```julia
julia> using Pkg
julia> Pkg.add("DoubleFloats")
```


## More Performant Than BigFloat

Comparing Double64 and BigFloat after setting BigFloat precision to 106 bits.

| op   | speedup |
|:-----|--------:|
| +    |     11x |
| *    |     18x |
| \    |      7x |
| trig |   3x-6x |
 _these results are from BenchmarkTools, on one machine_


## Examples

### Double64, Double32, Double16
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

julia> df64"0.2"
1.9999999999999999999999999999999937e-01
```

### Complex functions
```julia

julia> x = ComplexDF64(sqrt(df64"2"), cbrt(df64"3"))
1.4142135623730951 + 1.4422495703074083im

julia> y = acosh(x)
1.402873733241199 + 0.8555178360714634im

julia> x - cosh(y)
7.395570986446986e-32 + 0.0im
```
### show, string, parse
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

julia> x = ComplexDF32(sqrt(d32"2"), cbrt(d32"3"))
1.4142135 + 1.4422495im

julia> string(x)
"1.414213562373094 + 1.442249570307406im"

julia> stringtyped(x)
"ComplexDF32(Double32(1.4142135, 2.4203233e-8), Double32(1.4422495, 3.3793125e-8))"
```

### golden ratio
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

| typed value                      | computed value                   | ~abs(golden - computed) |
|:---------------------------------|:---------------------------------|:-----------------------:|
| `MathConstants.golden`           | 1.61803_39887_49894_84820_45868+ |           0.0           |
| `Float64(MathConstants.golden)`  | 1.61803_39887_49895              |         1.5e-16         |
| `Double32(MathConstants.golden)` | 1.61803_39887_49894_90           |         5.2e-17         |
| `Double64(MathConstants.golden)` | 1.61803_39887_49894_84820_45868_34365_6354 |         2.7e-33         |



## Questions

Usage questions can be posted on the [Julia Discourse forum](https://discourse.julialang.org/tags/doublefloats).  Use the topic `Numerics` (a "Discipline") and a put the package name, DoubleFloats, in your question ("topic").

## Contributions

Contributions are very welcome, as are feature requests and suggestions. Please open an [issue](https://github.com/JuliaMath/DoubleFloats.jl/issues) if you encounter any problems. The [contributing page](https://juliamath.github.io/DoubleFloats.jl/latest/man/contributing/) has a few guidelines that should be followed when opening pull requests.

----

<a name="involvement">β</a>: If you want to get involved with moving `Double32` performance forward, great. I would provide guidance. Otherwise, for most purposes you are better off using `Float64` than `Double32` (`Float64` has more significant bits, wider exponent range, and is much faster).

----


