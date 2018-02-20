# DoubleFloats


~~~~

- Use `Double` and `FastDouble` to obtain reliable `Float64` and `Float32` values.

```julia
using DoubleFloats

result = Float64.(calculate_result(x::Matrix{Double}))

# or

result = HI(calculate_result(x::Matrix{Double}))

```
