"""
__Predicates__ are functions that ask "yes or no" questions of their argument[s].     
You can ask of a number "Is this zero?" or "Is this one?" and these predicates
(`iszero`, `isone`) will work as expected with almost all numerical types.
The built-in numerical types let you query finiteness (`isfinite`, `isinf`).
These are the predicates made available for use with DoubleFloats:
> iszero, isnonzero, isone                 #  value == 0, value != 0, value == 1
  ispositive, isnegative,                  #  value >  0, value <  0
  isnonnegative, isnonpositive,            #  value >= 0, value <= 0   
  isinteger, isfractional                  #  value == round(value) 
  isfinite, isinf,                         #  abs(value) != Inf, abs(value) == Inf
  isposinf, isneginf,                      #  value == Inf, value == -Inf
  isnan                                    #  value is not a number (eg 0/0)
"""    

iszero(x::Double{T,E}) where {T<:Real,E<:Emphasis} =
    iszero(HI(x)) && iszero(LO(x))
    
isone(x::Double{T,E}) where {T<:Real,E<:Emphasis} =
    isone(HI(x)) && iszero(LO(x))
    
isnan(x::Double{T,E}) where {T<:Real,E<:Emphasis} =
    isnan(HI(x)) && iszero(LO(x))
    
isinf(x::Double{T,E}) where {T<:Real,E<:Emphasis} =
    isinf(HI(x)) && iszero(LO(x))

isfinite(x::Double{T,E}) where {T<:Real,E<:Emphasis} =
    isfinite(HI(x)) && isfinite(LO(x))
    
isinteger(x::Double{T,E}) where {T<:Real,E<:Emphasis} =
    isinteger(LO(x)) && isinteger(HI(x))
    
isodd(x::Double{T,E}) where {T<:Real,E<:Emphasis} =
    iszero(LO(x)) ? 
        isinteger(HI(x)) && isodd(HI(x)) :
        isinteger(LO(x)) && isodd(LO(x))
        
iseven(x::Double{T,E}) where {T<:Real,E<:Emphasis} =
    iszero(LO(x)) ?
        isinteger(HI(x)) && iseven(HI(x)) :
        isinteger(LO(x)) && iseven(LO(x))

issubnormal(x::Double{T,E}) where {T<:Real,E<:Emphasis} =
    issubnormal(HI(x)) || issubnormal(LO(x))

