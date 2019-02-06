# Construction

## from Integers, Floats and Rationals

```julia
using DoubleFloats

a1 = Double64(22) / 7
a2 = df64"22" / df64"7"
a1 === a2

b1 = Double32("5.12345") # prevent early conversion to Float64
b2 = df32"5.12345"
b1 === b2

c1 = Double16(22//7)
c2 = df16"22" / df16"7"
c1 === c2
```

## from two Reals

```julia
using DoubleFloats

a = 10.0
b = cbrt(10.0)
c = DoubleFloat(a, b)
```
__using this form is necessary when constructing a DoubleFloat from two numbers__
