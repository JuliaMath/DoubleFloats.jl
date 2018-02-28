zero(::Type{Double{T,E}}) where {T<:Real,E<:Emphasis} =
    Double(E, zero(T), zero(T))
iszero(x::Double{T,E}) where {T<:Real,E<:Emphasis} =
    iszero(HI(x)) && iszero(LO(x))
zero(::Type{Double}) = zero(Double{Float64, Accuracy})
zero(::Type{FastDouble}) = zero(Double{Float64, Performance})

one(::Type{Double{T,E}}) where {T<:Real,E<:Emphasis} =
   Double(E, one(T), zero(T))
isone(x::Double{T,E}) where {T<:Real,E<:Emphasis} =
    isone(HI(x)) && iszero(LO(x))
one(::Type{Double}) = one(Double{Float64, Accuracy})
one(::Type{FastDouble}) = one(Double{Float64, Performance})

nan(::Type{Double{T,E}}) where {T<:Real,E<:Emphasis} =
   Double(E, T(NaN), zero(T))
isnan(x::Double{T,E}) where {T<:Real,E<:Emphasis} =
    isnan(HI(x)) && iszero(LO(x))
nan(::Type{Double}) = nan(Double{Float64, Accuracy})
nan(::Type{FastDouble}) = nan(Double{Float64, Performance})

inf(::Type{Double{T,E}}) where {T<:Real,E<:Emphasis} =
   Double(E, T(Inf), zero(T))
isinf(x::Double{T,E}) where {T<:Real,E<:Emphasis} =
    isinf(HI(x)) && iszero(LO(x))
inf(::Type{Double}) = inf(Double{Float64, Accuracy})
inf(::Type{FastDouble}) = inf(Double{Float64, Performance})

isfinite(x::Double{T,E}) where {T<:Real,E<:Emphasis} =
    isfinite(HI(x)) && isfinite(LO(x))
isinteger(x::Double{T,E}) where {T<:Real,E<:Emphasis} =
    isinteger(LO(x)) && isinteger(HI(x))
isodd(x::Double{T,E}) where {T<:Real,E<:Emphasis} =
    iszero(LO(x)) ? isinteger(HI(x)) && isodd(HI(x)) : isinteger(LO(x)) && isodd(LO(x))
iseven(x::Double{T,E}) where {T<:Real,E<:Emphasis} =
    iszero(LO(x)) ? isinteger(HI(x)) && iseven(HI(x)) : isinteger(LO(x)) && iseven(LO(x))

issubnormal(x::Double{T,E}) where {T<:Real,E<:Emphasis} =
    issubnormal(HI(x)) || issubnormal(LO(x))

@inline (==)(x::Double{T,E}, y::Double{T,E}) where {T<:Real,E<:Emphasis} = (LO(x) === LO(y)) && (HI(x) === HI(y))
@inline (!=)(x::Double{T,E}, y::Double{T,E}) where {T<:Real,E<:Emphasis} = (LO(x) !== LO(y)) || (HI(x) !== HI(y))
@inline (<)(x::Double{T,E}, y::Double{T,E}) where {T<:Real,E<:Emphasis} = (HI(x) < HI(y)) || (HI(x) === HI(y) && LO(x) < LO(y))
@inline (>)(x::Double{T,E}, y::Double{T,E}) where {T<:Real,E<:Emphasis} = (HI(x) > HI(y)) || (HI(x) === HI(y) && LO(x) > LO(y))
@inline (<=)(x::Double{T,E}, y::Double{T,E}) where {T<:Real,E<:Emphasis} = (HI(x) < HI(y)) || (HI(x) === HI(y) && LO(x) <= LO(y))
@inline (>=)(x::Double{T,E}, y::Double{T,E}) where {T<:Real,E<:Emphasis} = (HI(x) > HI(y)) || (HI(x) === HI(y) && LO(x) >= LO(y))

@inline isequal(x::Double{T,E}, y::Double{T,E}) where {T<:Real,E<:Emphasis} = (x == y)
@inline isless(x::Double{T,E}, y::Double{T,E}) where {T<:Real,E<:Emphasis} = (x < y)

@inline (==)(x::Double{T,E}, y::T) where {T<:Real, E<:Emphasis} = iszero(LO(x)) && (HI(x) === y)
@inline (==)(x::T, y::Double{T,E}) where {T<:Real, E<:Emphasis} = iszero(LO(y)) && (HI(y) === x)
@inline (!=)(x::Double{T,E}, y::T) where {T<:Real, E<:Emphasis} = !iszero(LO(x)) || (HI(x) !== y)
@inline (!=)(x::T, y::Double{T,E}) where {T<:Real, E<:Emphasis} = !iszero(LO(y)) || (HI(y) !== x)
@inline (<)(x::Double{T,E}, y::T) where {T<:Real, E<:Emphasis} = (HI(x) < y) || ((HI(x) == y) && signbit(LO(x)))
@inline (<)(x::T, y::Double{T,E}) where {T<:Real, E<:Emphasis} = (x < HI(y)) || ((x == HI(y)) && !signbit(LO(y)))
@inline (>)(x::Double{T,E}, y::T) where {T<:Real, E<:Emphasis} = (HI(x) > y) || ((HI(x) == y) && (LO(x) < zero(T)))
@inline (>)(x::T, y::Double{T,E}) where {T<:Real, E<:Emphasis} = (x > HI(y)) || ((x == HI(y)) && signbit(LO(y)))
@inline (<=)(x::Double{T,E}, y::T) where {T<:Real, E<:Emphasis} = (HI(x) < y) || ((HI(x) == y) && (LO(x) <= zero(T)))
@inline (<=)(x::T, y::Double{T,E}) where {T<:Real, E<:Emphasis} = (x < HI(y)) || ((x == HI(y)) && (LO(y) >= zero(T)))
@inline (>=)(x::Double{T,E}, y::T) where {T<:Real, E<:Emphasis} = (HI(x) > y) || ((HI(x) == y) && (LO(x) <= zero(T)))
@inline (>=)(x::T, y::Double{T,E}) where {T<:Real, E<:Emphasis} = (x > HI(y)) || ((x == HI(y)) && (LO(y) >= zero(T)))

@inline isequal(x::Double{T,E}, y::T) where {T<:Real, E<:Emphasis} = (x == y)
@inline isequal(x::T, y::Double{T,E}) where {T<:Real, E<:Emphasis} = (x == y)
@inline isless(x::Double{T,E}, y::T) where {T<:Real, E<:Emphasis} = (x < y)
@inline isless(x::T, y::Double{T,E}) where {T<:Real, E<:Emphasis} = (x < y)
