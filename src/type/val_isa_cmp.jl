import Base: zero, one, Inf, NaN,
             iszero, isinf, isnan, isfinite, isinteger, isodd, iseven,
             :(==), :(!=), :(<), :(<=), :(>=), :(>), isless, isequal

if VERSION >= v"0.7.0-" 
    import Base:isone
else
    export isone
end

zero(::Type{DoubleFloat{T,E}}) where {T<:Real,E<:Emphasis} =
    DoubleFloat(E, zero(T), zero(T))
iszero(x::DoubleFloat{T,E}) where {T<:Real,E<:Emphasis} =
    iszero(hi(x)) && iszero(lo(x))

one(::Type{DoubleFloat{T,E}}) where {T<:Real,E<:Emphasis} = 
   DoubleFloat(E, one(T), zero(T))
isone(x::DoubleFloat{T,E}) where {T<:Real,E<:Emphasis} =
    isone(hi(x)) && iszero(lo(x))

NaN(::Type{DoubleFloat{T,E}}) where {T<:Real,E<:Emphasis} = 
   DoubleFloat(E, T(NaN), zero(T))
isnan(x::DoubleFloat{T,E}) where {T<:Real,E<:Emphasis} =
    isnan(hi(x)) && iszero(lo(x))

Inf(::Type{DoubleFloat{T,E}}) where {T<:Real,E<:Emphasis} = 
   DoubleFloat(E, T(Inf), zero(T))
isinf(x::DoubleFloat{T,E}) where {T<:Real,E<:Emphasis} =
    isinf(hi(x)) && iszero(lo(x))

isfinite(x::DoubleFloat{T,E}) where {T<:Real,E<:Emphasis} =
    isfinite(hi(x)) && isfinite(lo(x))
isinteger(x::DoubleFloat{T,E}) where {T<:Real,E<:Emphasis} =
    isinteger(lo(x)) && isinteger(hi(x))
isodd(x::DoubleFloat{T,E}) where {T<:Real,E<:Emphasis} =
    iszero(lo(x)) ? isinteger(hi(x)) && isodd(hi(x)) : isinteger(lo(x)) && isodd(lo(x))
iseven(x::DoubleFloat{T,E}) where {T<:Real,E<:Emphasis} =
    iszero(lo(x)) ? isinteger(hi(x)) && iseven(hi(x)) : isinteger(lo(x)) && iseven(lo(x))

issubnormal(x::DoubleFloat{T,E}) where {T<:Real,E<:Emphasis} =
    issubnormal(hi(x)) || issubnormal(lo(x))



@inline (==)(x::Double{T,E}, y::Double{T,E}) where {T<:Number,E<:Emphasis} = (lo(x) === lo(y)) && (hi(x) === hi(y))
@inline (!=)(x::Double{T,E}, y::Double{T,E}) where {T<:Number,E<:Emphasis} = (lo(x) !== lo(y)) || (hi(x) !== hi(y))
@inline (<)(x::Double{T,E}, y::Double{T,E}) where {T<:Number,E<:Emphasis} = (hi(x) < hi(y)) || (hi(x) === hi(y) && lo(x) < lo(y))
@inline (>)(x::Double{T,E}, y::Double{T,E}) where {T<:Number,E<:Emphasis} = (hi(x) > hi(y)) || (hi(x) === hi(y) && lo(x) > lo(y))
@inline (<=)(x::Double{T,E}, y::Double{T,E}) where {T<:Number,E<:Emphasis} = (hi(x) < hi(y)) || (hi(x) === hi(y) && lo(x) <= lo(y))
@inline (>=)(x::Double{T,E}, y::Double{T,E}) where {T<:Number,E<:Emphasis} = (hi(x) > hi(y)) || (hi(x) === hi(y) && lo(x) >= lo(y))

@inline isequal(x::Double{T,E}, y::Double{T,E}) where {T<:Number,E<:Emphasis} = (x == y)
@inline isless(x::Double{T,E}, y::Double{T,E}) where {T<:Number,E<:Emphasis} = (x < y)


