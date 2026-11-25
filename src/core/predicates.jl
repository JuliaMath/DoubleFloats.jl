"""
__Predicates__ are functions that ask "yes or no" questions of their argument[s].
You can ask of a number "Is this zero?" or "Is this one?" and these predicates
(`iszero`, `isone`) will work as expected with almost all numerical types.
The built-in numerical types let you query finiteness (`isfinite`, `isinf`).
These are the predicates made available for use with DoubleFloats:

> iszero, isnonzero, isone                 #  value == 0, value != 0, value == 1
  ispositive, isnegative,                  #  value >  0, value <  0
  isnonnegative, isnonpositive,            #  value >= 0, value <= 0
  isfinite, isinf,                         #  abs(value) != Inf, abs(value) == Inf
  isposinf, isneginf,                      #  value == Inf, value == -Inf
  isnan,                                   #  value is not a number (eg 0/0)
  issubnormal,                             #  value contains a subnormal part
  isnormal,                                #  value is finite and not subnormal
  isinteger, isfractional                  #  value == round(value)
  iseven, isodd,                           #  isinteger(value/2.0), !isinteger(value/2.0)
"""
predicates

"""
    isnonzero(x)

Return `!iszero(x)`
"""
isnonzero(x::T) where {T<:AbstractFloat} = !iszero(x)

@static if !isdefined(Base, :ispositive)
    ispositive(x::T) where {T<:AbstractFloat} = !isnegative(x) && isnonzero(x)
end

"""
    isnonnegative(x)

Returns `true` if `!isnegative(x)`.
"""
isnonnegative(x::T) where {T<:AbstractFloat} = !isnegative(x)
"""
    isnonpositive(x)

Returns `true` if `isnegative(x)` or `iszero(x)`.
"""
isnonpositive(x::T) where {T<:AbstractFloat} = isnegative(x) || iszero(x)

"""
    isfractional(x)

Returns `true` if `abs(x) < one(x)`.
"""
isfractional(x::T) where {T<:AbstractFloat} = abs(x) < one(T)

Base.iszero(x::DoubleFloat{T}) where {T<:IEEEFloat} = iszero(HI(x)) # && iszero(LO(x))

isnonzero(x::DoubleFloat{T}) where {T<:IEEEFloat} = !iszero(HI(x)) # || !iszero(LO(x))

Base.isone(x::DoubleFloat{T}) where {T<:IEEEFloat} = isone(HI(x)) && iszero(LO(x))

"""
    ispositive(x)

Returns `true` if `!isnegative(x)` and `isnonzero(x)`.
"""
ispositive(x::DoubleFloat{T}) where {T<:IEEEFloat} = !signbit(HI(x)) && !iszero(HI(x))

"""
    isnegative(x)

Return `true` if `signbit(HI(x))` is `true`.
"""
isnegative(x::DoubleFloat{T}) where {T<:IEEEFloat} = signbit(HI(x))

isnonnegative(x::DoubleFloat{T}) where {T<:IEEEFloat} = !signbit(HI(x))

isnonpositive(x::DoubleFloat{T}) where {T<:IEEEFloat} = signbit(HI(x)) || iszero(HI(x))

Base.isfinite(x::DoubleFloat{T}) where {T<:IEEEFloat} = isfinite(HI(x))

Base.isinf(x::DoubleFloat{T}) where {T<:IEEEFloat} = isinf(HI(x))

"""
    isposinf(x)

Tests whether a number is positive and infinite.
"""
isposinf(x::DoubleFloat{T}) where {T<:IEEEFloat} = isinf(HI(x)) && !signbit(HI(x))

"""
    isneginf(x)

Tests whether a number is negative and infinite.
"""
isneginf(x::DoubleFloat{T}) where {T<:IEEEFloat} = isinf(HI(x)) && signbit(HI(x))

Base.isnan(x::DoubleFloat{T}) where {T<:IEEEFloat} = isnan(HI(x))

Base.issubnormal(x::DoubleFloat{T}) where {T<:IEEEFloat} = issubnormal(LO(x)) || issubnormal(HI(x))

"""
    isnormal(x)

Tests whether a floating point number is normal.
"""
isnormal(x::DoubleFloat{T}) where {T<:IEEEFloat} = isfinite(HI(x)) && !iszero(x) && (abs(x) >= floatmin(T))

@inline Base.isinteger(x::DoubleFloat{T}) where {T<:IEEEFloat} = isinteger(HI(x)) && isinteger(LO(x))

isfractional(x::DoubleFloat{T}) where {T<:IEEEFloat} = !isinteger(LO(x)) || !isinteger(HI(x))

Base.isodd(x::DoubleFloat{T}) where {T<:IEEEFloat} =
    if isinteger(x)
        (iszero(LO(x)) && isodd(HI(x))) || isodd(LO(x))
    else
        false
    end

Base.iseven(x::DoubleFloat{T}) where {T<:IEEEFloat} =
    if isinteger(x)
        (iszero(LO(x)) && iseven(HI(x))) || iseven(LO(x))
    else
        false
    end

"""
    isnormalized(x::DoubleFloat)

Whether the high word of `x` is the sum of its two words rounded to nearest.
Every value the package returns is normalized; a value that is not finite
counts as normalized whatever its low word.
"""
isnormalized(x::DoubleFloat) = !isfinite(HI(x)) | (HI(x) + LO(x) == HI(x))
