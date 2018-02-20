# DoubleFloats.jl
### Floating point math with 100+ bit accurate significand; fast ops with 88+ bit accuracy.

### [**Appropriate Use**](https://github.com/JuliaMath/DoubleFloats.jl/blob/master/docs/src/appropriate.md)

-----

```julia
using DoubleFloats

setprecision(Double, 256)
half = Double{128}(0.5)
five = Double(5)

precision(half) == 128
precision(five) == 256

```



| this package is under development |
|-----------------------------------|
| repository created on 2018-01-25  |
