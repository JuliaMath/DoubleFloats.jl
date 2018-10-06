# names

__DoubleFloats__ is the package.  `Double64` and `Double32` are the exported types.

`Double64s` store 106 significand bits, 11 exponent bits and two sign bits (one for the higher order Float64 and one for the lower order Float64, and they often differ).  This gives `Double64s` twice the significand bits of a Float64 with the same exponent range as a Float64.

`Double32s` store 48 significand bits, 8 exponent bits and two sign bits (one for the higher order Float32 and one for the lower order Float32, and they often differ).  This gives `Double32s` twice the significand bits of a Float32 with the same exponent range as a Float32.
