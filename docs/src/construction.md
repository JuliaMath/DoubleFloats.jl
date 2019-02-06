# Construction

## from Integers, Floats and Irrationals

```julia
using DoubleFloats

a1 = Double64(22) / 17
a2 = DblF64"22" / DblF64"17"
a1 === a2

b1 = Double32("5.12345") # prevent early conversion to Float64
b2 = DblF32"5.12345"
b1 === b2

```

## from two Reals

```julia
using DoubleFloats

a = 10.0
b = cbrt(10.0)
c = DoubleFloat(a, b)
```
__using this form is necessary when constructing a DoubleFloat from two numbers__
