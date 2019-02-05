# Construction

## from Integers, Floats and Irrationals

```julia
using DoubleFloats

a = Double64(pi)
b = Double32("5.12345") # prevent early conversion to Float64

a = d64"pi"
b = d32"5"
c = d16"1.125"

```

## from two Reals

```julia
using DoubleFloats

a = 10.0
b = cbrt(10.0)
c = DoubleFloat(a, b)
```
__using this form is necessary when constructing a DoubleFloat from two numbers__
