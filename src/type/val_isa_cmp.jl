import Base: zero, one, Inf, NaN,
             iszero, isinf, isnan, isfinite, isinteger, isodd, iseven,
             (==), (!=), (<), (<=), (>=), (>), isless, isequal

if VERSION >= v"0.7.0-" 
    import Base:isone
else
    export isone
end

zero(::Type{Double{T,E}}) where {T<:Real,E<:Emphasis} =
    Double(E, zero(T), zero(T))
iszero(x::Double{T,E}) where {T<:Real,E<:Emphasis} =
    iszero(hi(x)) && iszero(lo(x))

one(::Type{Double{T,E}}) where {T<:Real,E<:Emphasis} = 
   Double(E, one(T), zero(T))
isone(x::Double{T,E}) where {T<:Real,E<:Emphasis} =
    isone(hi(x)) && iszero(lo(x))

nan(::Type{Double{T,E}}) where {T<:Real,E<:Emphasis} = 
   Double(E, T(NaN), zero(T))
isnan(x::Double{T,E}) where {T<:Real,E<:Emphasis} =
    isnan(hi(x)) && iszero(lo(x))

Inf(::Type{Double{T,E}}) where {T<:Real,E<:Emphasis} = 
   Double(E, T(Inf), zero(T))
isinf(x::Double{T,E}) where {T<:Real,E<:Emphasis} =
    isinf(hi(x)) && iszero(lo(x))

isfinite(x::Double{T,E}) where {T<:Real,E<:Emphasis} =
    isfinite(hi(x)) && isfinite(lo(x))
isinteger(x::Double{T,E}) where {T<:Real,E<:Emphasis} =
    isinteger(lo(x)) && isinteger(hi(x))
isodd(x::Double{T,E}) where {T<:Real,E<:Emphasis} =
    iszero(lo(x)) ? isinteger(hi(x)) && isodd(hi(x)) : isinteger(lo(x)) && isodd(lo(x))
iseven(x::Double{T,E}) where {T<:Real,E<:Emphasis} =
    iszero(lo(x)) ? isinteger(hi(x)) && iseven(hi(x)) : isinteger(lo(x)) && iseven(lo(x))

issubnormal(x::Double{T,E}) where {T<:Real,E<:Emphasis} =
    issubnormal(hi(x)) || issubnormal(lo(x))



@inline (==)(x::Double{T,E}, y::Double{T,E}) where {T<:Real,E<:Emphasis} = (lo(x) === lo(y)) && (hi(x) === hi(y))
@inline (!=)(x::Double{T,E}, y::Double{T,E}) where {T<:Real,E<:Emphasis} = (lo(x) !== lo(y)) || (hi(x) !== hi(y))
@inline (<)(x::Double{T,E}, y::Double{T,E}) where {T<:Real,E<:Emphasis} = (hi(x) < hi(y)) || (hi(x) === hi(y) && lo(x) < lo(y))
@inline (>)(x::Double{T,E}, y::Double{T,E}) where {T<:Real,E<:Emphasis} = (hi(x) > hi(y)) || (hi(x) === hi(y) && lo(x) > lo(y))
@inline (<=)(x::Double{T,E}, y::Double{T,E}) where {T<:Real,E<:Emphasis} = (hi(x) < hi(y)) || (hi(x) === hi(y) && lo(x) <= lo(y))
@inline (>=)(x::Double{T,E}, y::Double{T,E}) where {T<:Real,E<:Emphasis} = (hi(x) > hi(y)) || (hi(x) === hi(y) && lo(x) >= lo(y))

@inline isequal(x::Double{T,E}, y::Double{T,E}) where {T<:Real,E<:Emphasis} = (x == y)
@inline isless(x::Double{T,E}, y::Double{T,E}) where {T<:Real,E<:Emphasis} = (x < y)


@inline (==)(x::Double{T,E}, y::T) where {T<:Real, E<:Emphasis} = iszero(lo(x)) && (hi(x) === y)
@inline (==)(x::T, y::Double{T,E}) where {T<:Real, E<:Emphasis} = iszero(lo(y)) && (hi(y) === x)
@inline (!=)(x::Double{T,E}, y::T) where {T<:Real, E<:Emphasis} = !iszero(lo(x)) || (hi(x) !== y)
@inline (!=)(x::T, y::Double{T,E}) where {T<:Real, E<:Emphasis} = !iszero(lo(y)) || (hi(y) !== x)
@inline (<)(x::Double{T,E}, y::T) where {T<:Real, E<:Emphasis} = (hi(x) < y) || ((hi(x) == y) && signbit(lo(x)))
@inline (<)(x::T, y::Double{T,E}) where {T<:Real, E<:Emphasis} = (x < hi(y)) || ((x == hi(y)) && !signbit(lo(y)))
@inline (>)(x::Double{T,E}, y::T) where {T<:Real, E<:Emphasis} = (hi(x) > y) || ((hi(x) == y) && (lo(x) < zero(T)))
@inline (>)(x::T, y::Double{T,E}) where {T<:Real, E<:Emphasis} = (x > hi(y)) || ((x == hi(y)) && signbit(lo(y)))
@inline (<=)(x::Double{T,E}, y::T) where {T<:Real, E<:Emphasis} = (hi(x) < y) || ((hi(x) == y) && (lo(x) <= zero(T)))
@inline (<=)(x::T, y::Double{T,E}) where {T<:Real, E<:Emphasis} = (x < hi(y)) || ((x == hi(y)) && (lo(y) >= zero(T)))
@inline (>=)(x::Double{T,E}, y::T) where {T<:Real, E<:Emphasis} = (hi(x) > y) || ((hi(x) == y) && (lo(x) <= zero(T)))
@inline (>=)(x::T, y::Double{T,E}) where {T<:Real, E<:Emphasis} = (x > hi(y)) || ((x == hi(y)) && (lo(y) >= zero(T)))

@inline isequal(x::Double{T,E}, y::T) where {T<:Real, E<:Emphasis} = (x == y)
@inline isequal(x::T, y::Double{T,E}) where {T<:Real, E<:Emphasis} = (x == y)
@inline isless(x::Double{T,E}, y::T) where {T<:Real, E<:Emphasis} = (x < y)
@inline isless(x::T, y::Double{T,E}) where {T<:Real, E<:Emphasis} = (x < y)
