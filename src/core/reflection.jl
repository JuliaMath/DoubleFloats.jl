@inline Base.signbit(a::DoubleFloat{T}) where {T} = signbit(HI(a))
@inline Base.sign(a::DoubleFloat{T}) where {T} = DoubleFloat{T}(sign(HI(a)))

@inline function (Base.:(-))(a::DoubleFloat{T}) where {T<:IEEEFloat}
    if iszero(LO(a)) || isnan(LO(a))
        unsafe_double(T, -HI(a), LO(a))
    else
        unsafe_double(T, -HI(a), -LO(a))
    end
end

@inline function Base.abs(a::DoubleFloat{T}) where {T<:IEEEFloat}
    (!signbit(a) || isnan(a)) && return a
    return -a
end

"""
    frexps(x::DoubleFloat)

Applies `Base.frexp` to both `hi` and `lo` parts, and returns a tuple of tuples.
See also `DoubleFloats.ldexps` for the inverse, and `DoubleFloats.signs` similar tuple.
"""
function frexps(x::DoubleFloat{T}) where {T<:IEEEFloat}
    frhi, exphi = frexp(HI(x))
    frlo, explo = frexp(LO(x))
    return (frhi, exphi), (frlo, explo)
end

function Base.Math.frexp(x::DoubleFloat{T}) where {T<:IEEEFloat}
    frhi, exphi = frexp(HI(x))
    frlo, explo = frexp(LO(x))
    return unsafe_double(T, frhi, ldexp(frlo, explo - exphi)), exphi
end

function Base.Math.ldexp(x::DoubleFloat{T}, exponent::I) where {T<:IEEEFloat,I<:Integer}
    return unsafe_double(T, ldexp(HI(x), exponent), ldexp(LO(x), exponent))
end

function ldexps(dhi::Tuple{T,I}, dlo::Tuple{T,I}) where {T<:IEEEFloat,I<:Integer}
    return DoubleFloat(ldexp(dhi[1], dhi[2]), ldexp(dlo[1], dlo[2]))
end

function ldexps(dhilo::Tuple{Tuple{T,I},Tuple{T,I}}) where {T<:IEEEFloat,I<:Integer}
    return ldexp(dhilo[1], dhilo[2])
end

# Base contract: exponent returns the Int e with 2^e <= |x| < 2^(e+1),
# and significand returns x / 2^e.  (These once returned per-word tuples,
# which broke any Base code that calls them -- e.g. sqrt(::Complex) via
# ssqs, which sank the Complex{Double32} Schur path.)
function Base.exponent(x::DoubleFloat{T}) where {T<:IEEEFloat}
    e = Base.exponent(HI(x))
    # a hi word exactly at a binade boundary with an opposing lo word puts
    # |x| just below 2^e
    if !iszero(LO(x)) && (signbit(LO(x)) != signbit(HI(x))) && abs(HI(x)) == ldexp(one(T), e)
        e -= 1
    end
    return e
end

function Base.significand(x::DoubleFloat{T}) where {T<:IEEEFloat}
    return ldexp(x, -exponent(x))
end

function signs(x::DoubleFloat{T}) where {T<:IEEEFloat}
    shi = sign(HI(x))
    slo = sign(LO(x))
    return shi, slo
end

ulp(x::T) where {T<:IEEEFloat} = significand(x) !== -one(T) ? eps(x) : eps(x)/2

posulp(x::T) where {T<:IEEEFloat} = significand(x) !== -one(T) ? eps(x) : eps(x)/2
negulp(x::T) where {T<:IEEEFloat} = significand(x) !== one(T) ? -eps(x) : -eps(x)/2

ulp(::Type{T}) where {T<:IEEEFloat} = ulp(one(T))
posulp(::Type{T}) where {T<:IEEEFloat} = ulp(one(T))
negulp(::Type{T}) where {T<:IEEEFloat} = ulp(one(T))

function Base.eps(x::DoubleFloat{T}) where {T<:IEEEFloat}
    return LO(x) !== zero(T) ? eps(LO(x)) : eps(posulp(HI(x)))
end

function ulp(x::DoubleFloat{T}) where {T<:IEEEFloat}
    return LO(x) !== zero(T) ? posulp(LO(x)) : posulp(posulp(HI(x)))
end

Base.eps(::Type{D}) where {T<:AbstractFloat,D<:DoubleFloat{T}} = D(eps(posulp(one(T))))
ulp(::Type{D}) where {T<:AbstractFloat,D<:DoubleFloat{T}} = D(posulp(poslulp(one(T))))

function Base.nextfloat(x::DoubleFloat{T}) where {T<:IEEEFloat}
    if !isfinite(x)
        isnan(x) && return x
        signbit(x) ? floatmin(DoubleFloat{T}) : x
    elseif !iszero(LO(x))
        DoubleFloat{T}(HI(x)) + nextfloat(LO(x))
    else
        unsafe_double(T, HI(x), ulp(ulp(HI(x))))
    end
end

function Base.prevfloat(x::DoubleFloat{T}) where {T<:IEEEFloat}
    if !isfinite(x)
        isnan(x) && return x
        signbit(x) ? x : floatmax(DoubleFloat{T})
    elseif !iszero(LO(x))
        DoubleFloat{T}(HI(x)) + prevfloat(LO(x))
    else
        unsafe_double(T, HI(x), -ulp(ulp(HI(x))))
    end
end

function Base.nextfloat(x::DoubleFloat{T}, n::Int) where {T<:IEEEFloat}
    !isfinite(x) && return (x)
    if !iszero(LO(x))
        x + n*ulp(LO(x))
    else
        unsafe_double(T, HI(x), n*ulp(ulp(HI(x))))
    end
end

function Base.prevfloat(x::DoubleFloat{T}, n::Int) where {T<:IEEEFloat}
    !isfinite(x) && return (x)
    if !iszero(LO(x))
        x - n*ulp(LO(x))
    else
        unsafe_double(T, HI(x), -n*ulp(ulp(HI(x))))
    end
end

@inline function intpart(x::Tuple{T,T}) where {T<:AbstractFloat}
    hi, lo = x
    ihi = modf(hi)[2]
    ilo = modf(lo)[2]
    return two_sum(ihi, ilo)
end

@inline function fracpart(x::Tuple{T,T}) where {T<:AbstractFloat}
    hi, lo = x
    fhi = modf(hi)[1]
    flo = modf(lo)[1]
    return two_sum(fhi, flo)
end

function intpart(x::DoubleFloat{T}) where {T<:IEEEFloat}
    ihi, ilo = intpart(HILO(x))
    return unsafe_double(T, ihi, ilo)
end

function fracpart(x::DoubleFloat{T}) where {T<:IEEEFloat}
    fhi, flo = fracpart(HILO(x))
    return unsafe_double(T, fhi, flo)
end

"""
    modf(x::DoubleFloat)

The fractional and integer parts of `x`, as `Base.modf` defines them: both
carry the sign of `x`, the fraction is less than one in magnitude, and their
sum is `x` exactly.
"""
function Base.modf(x::DoubleFloat{T}) where {T<:IEEEFloat}
    hi, lo = HILO(x)
    isnan(hi) && return (x, x)
    signedzero = unsafe_double(T, copysign(zero(T), hi), zero(T))
    isinf(hi) && return (signedzero, x)
    fhi, ihi = modf(hi)
    if !iszero(fhi)
        # The fraction begins in the high word; the low word is all fraction
        # and smaller than the fraction of the high word.
        f = DoubleFloat{T}(fhi, lo)
        i = unsafe_double(T, ihi, zero(T))
    else
        flo, ilo = modf(lo)
        if !iszero(flo) && signbit(flo) != signbit(hi)
            # The high word is an integer and the low word pulls the value
            # just inside it: move one unit from the integer part.
            unit = copysign(one(T), hi)
            f = DoubleFloat{T}(unit, flo)
            i = DoubleFloat{T}(hi, ilo - unit)
        else
            f = unsafe_double(T, flo, zero(T))
            i = DoubleFloat{T}(hi, ilo)
        end
    end
    return (iszero(HI(f)) ? signedzero : f, iszero(HI(i)) ? signedzero : i)
end

function fmod(fpart::DoubleFloat{T}, ipart::DoubleFloat{T}) where {T<:IEEEFloat}
    return ipart + fpart
end

function fmod(parts::Tuple{DoubleFloat{T},DoubleFloat{T}}) where {T<:IEEEFloat}
    return parts[1] + parts[2]
end
