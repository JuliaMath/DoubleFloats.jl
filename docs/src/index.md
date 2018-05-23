
# DoubleFloats



## Introduction

When you are `using DoubleFloats`, you have three more floating point types:
- `DoubleF64` is a magnitude ordered, nonoverlapping pair of Float64s
- `DoubleF32` is a magnitude ordered, nonoverlapping pair of Float32s
- `DoubleF16` is a magnitude ordered, nonoverlapping pair of Float16s

Many arithmetic operations and elementary functions are available with each type.

- flipsign, copysign, signbit, sign, abs
- ==, !=, <, <=, >=, >, isless, isequal
- +, -, *, /, ^, floor, ceil, trunc, round (to integer)
- square, cube, sqrt, cbrt
- hypot, normalize
- exp, expm1, log, log1p
- sin, cos, tan, csc, sec, cot
- asin, acos, atan, acsc, asec, acot
- sinh, cosh, tanh, csch, sech, coth
- asinh, acosh, atanh, acsch, asech, acoth

- todo: div, fld, cld, rem, mod, divrem, fldmod, round (fractionally), atan2


These types are identical in coverage and compatibility. Any function that knows of one knows of both.
Every function that is imported from Base.Math and overloaded in order to just work and work well with
`Doubles` will do the same with `FastDoubles`.  And they utilize identical code for some of their work.


----

- ## [Overview](https://github.com/JuliaMath/DoubleFloats.jl/blob/master/docs/src/appropriate.md)
- ## [Capabilities](https://github.com/JuliaMath/DoubleFloats.jl/blob/master/docs/src/capabilities.md#capabilities)

- ### [reference material](https://github.com/JuliaMath/DoubleFloats.jl/blob/master/docs/src/references.md)

