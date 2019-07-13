## Capabilities


### predicates


__Predicates__ are functions that ask "yes or no" questions of their argument[s].      
You can ask of a number "Is this zero?" or "Is this one?" and these predicates    
(`iszero`, `isone`) will work as expected with almost all numerical types.    
The built-in numerical types let you query finiteness (`isfinite`, `isinf`).    

These are the predicates made available for use with DoubleFloats:    
```julia
  iszero, isnonzero, isone                 #  value == 0, value != 0, value == 1
  ispositive, isnegative,                  #  value >  0, value <  0
  isnonnegative, isnonpositive,            #  value >= 0, value <= 0   
  isinteger, isfractional,                 #  value == round(value)
  issubnormal,                             #  zero(T) < abs(value) < floatmin(T)
  isnormal,                                #  !isinf(value) && !isnan(value) && !issubnormal(value)
  isfinite, isinf,                         #  abs(value) != Inf, abs(value) == Inf
  isposinf, isneginf,                      #  value == Inf, value == -Inf
  isnan                                    #  value is not a number (eg 0/0)
```    


#### the basic arithmetic operations
- addition, subtraction 
- multiplication, square, cube
- reciprocation, division, square root, cube root

There are arithmetic operations that take two Float64s or Float32s or Float16s and return the corresponding Double64 or Double32 or Double16.  These operations are available in functional form as `add2`, `sub2`, `mul2`, `div2` and in infix form using "⊕ ⊖ ⊗ ⊘" ( \oplus \ominus \otimes \oslash).

#### rounding
- `RoundNearest`, `RoundUp`, `RoundDown`
- `RoundToZero`, `RoundFromZero`

- `spread`
    -- the nearest integer to x, away from zero; spread complements `trunc`.
- `tld(x,y) = trunc(x/y)`
- `sld(x,y) = spread(s/y)`

#### elementary mathematical functions
 - `log`, `exp`
 - `sin`, `cos`, `tan`, `csc`, `sec`, `cot`
 - `sinpi`, `cospi`, `tanpi`
 - `asin`, `acos`, `atan`, `acsc`, `asec`, `acot`
 - `sinh`, `cosh`, `tanh`, `csch`, `sech`, `coth`
 - `asinh`, `acosh`, `atanh`, `acsch`, `asech`, `acoth`

#### linear algebra
 - `isdiag`, `ishermitian`, `isposdef`, `issymmetric`, `istril`, `istriu`
 - `norm`, `det`, `dot`, `tr`, `condskeel`, `logdet`, `logabsdet`
 - `transpose`, `adjoint`, `tril`, `triu`
 - `diag`, `diagind`
 - `factorize`, `lu`, `lufact`, `qr`, `qrfact`
 
#### also
 - `rand` for uniform variates in [0,1)
 - `randn` for canonical normal variates
 - `isapprox` (default `rtol=eps(1.0)^(37/64)`)
