""""
__Predicates__ are functions that ask "yes or no" questions of their argument[s].
You can ask of a number "Is this zero?" or "Is this one?" and these predicates
(`iszero`, `isone`) will work as expected with almost all numerical types.
The built-in numerical types let you query finiteness (`isfinite`, `isinf`).
These are the predicates made available for use with DoubleFloats:

> iszero, isnonzero, isone                 #  value == 0, value != 0, value == 1
  ispos, isneg,                            #  value >  0, value <  0
  isnonneg, isnonpos,                      #  value >= 0, value <= 0
  isfinite, isinf,                         #  abs(value) != Inf, abs(value) == Inf
  isposinf, isneginf,                      #  value == Inf, value == -Inf
  isnan,                                   #  value is not a number (eg 0/0)
  issubnormal,                             #  value contains a subnormal part
  isnormal,                                #  value is finite and not subnormal
  isinteger, isfractional                  #  value == round(value)
  iseven, isodd,                           #  isinteger(value/2.0), !isinteger(value/2.0)
""" predicates

"""
    isnonzero(x)

Return `!iszero(x)`
"""
isnonzero(x::T) where {T<:AbstractFloat} = !iszero(x)

"""
    ispos(x)

Returns `true` if `!isneg(x)` and `isnonzero(x)`.
"""
ispos(x::T) where {T<:AbstractFloat} = !isneg(x) && isnonzero(x)

"""
    isnonneg(x)

Returns `true` if `!isneg(x)`.
"""
isnonneg(x::T) where {T<:AbstractFloat} = !isneg(x)

"""
    isnonpos(x)

Returns `true` if `isneg(x)` or `iszero(x)`.
"""
isnonpos(x::T) where {T<:AbstractFloat} = isneg(x) || iszero(x)

"""
    isfractional(x)

Returns `true` if `abs(x) < one(x)`.
"""
isfractional(x::T) where {T<:AbstractFloat} = abs(x) < one(T)


iszero(x::DoubleFloat{T}) where {T<:AbstractFloat} =
    iszero(HI(x)) # && iszero(LO(x))

isnonzero(x::DoubleFloat{T}) where {T<:AbstractFloat} =
    !iszero(HI(x)) # || !iszero(LO(x))

isone(x::DoubleFloat{T}) where {T<:AbstractFloat} =
    isone(HI(x)) && iszero(LO(x))

ispos(x::DoubleFloat{T}) where {T<:AbstractFloat} =
    !signbit(HI(x)) && !iszero(HI(x))

"""
    isneg(x)

Return `true` if `signbit(HI(x))` is `true`.
"""
isneg(x::DoubleFloat{T}) where {T<:AbstractFloat} =
    signbit(HI(x))

isnonneg(x::DoubleFloat{T}) where {T<:AbstractFloat} =
    !signbit(HI(x))

isnonpos(x::DoubleFloat{T}) where {T<:AbstractFloat} =
    signbit(HI(x)) || iszero(HI(x))

isfinite(x::DoubleFloat{T}) where {T<:AbstractFloat} =
    isfinite(HI(x)) ## && isfinite(LO(x))

isinf(x::DoubleFloat{T}) where {T<:AbstractFloat} =
    isinf(HI(x)) && iszero(LO(x))

"""
    isposinf(x)

Tests whether a number positive and infinite.
"""
isposinf(x::DoubleFloat{T}) where {T<:AbstractFloat} =
    isinf(HI(x)) && !signbit(HI(x))

"""
    isneginf(x)

Tests whether a number is negative and infinite.
"""
isneginf(x::DoubleFloat{T}) where {T<:AbstractFloat} =
    isinf(HI(x)) && signbit(HI(x))

isnan(x::DoubleFloat{T}) where {T<:AbstractFloat} =
    isnan(HI(x)) ## && iszero(LO(x))

issubnormal(x::DoubleFloat{T}) where {T<:AbstractFloat} =
    issubnormal(LO(x)) || issubnormal(HI(x))

"""
    isnormal(x)

Tests whether a floating point number is normal.
"""
isnormal(x::DoubleFloat{T}) where {T<:AbstractFloat} =
    isfinite(HI(x)) && !iszero(x) && (abs(x) >= floatmin(T))

isinteger(x::DoubleFloat{T}) where {T<:AbstractFloat} =
    isinteger(HI(x)) && isinteger(LO(x))

isfractional(x::DoubleFloat{T}) where {T<:AbstractFloat} =
    !isinteger(LO(x)) || !isinteger(HI(x))

isodd(x::DoubleFloat{T}) where {T<:AbstractFloat} =
    iszero(LO(x)) ?
        isinteger(HI(x)) && isodd(HI(x)) :
        isinteger(LO(x)) && isodd(LO(x))

iseven(x::DoubleFloat{T}) where {T<:AbstractFloat} =
    iszero(LO(x)) ?
        isinteger(HI(x)) && iseven(HI(x)) :
        isinteger(LO(x)) && iseven(LO(x))
