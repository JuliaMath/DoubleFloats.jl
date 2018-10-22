@inline signbit(a::DoubleFloat{T}) where {T} = signbit(HI(a))
@inline sign(a::DoubleFloat{T}) where {T} = sign(HI(a))

@inline function (-)(a::DoubleFloat{T}) where {T}
    if iszero(LO(a))
        DoubleFloat(-HI(a), LO(a))
    else
        DoubleFloat(-HI(a), -LO(a))
    end
end

@inline function abs(a::DoubleFloat{T}) where {T}
    if HI(a) >= 0.0
        a
    else # HI(a) < 0.0
        -a
    end
end


@inline function flipsign(x::DoubleFloat{T}, y::T) where {T<:AbstractFloat}
    signbit(y) ? -x : x
end
@inline function flipsign(x::DoubleFloat{T}, y::DoubleFloat{T}) where {T<:AbstractFloat}
    signbit(y) ? -x : x
end

@inline function copysign(x::DoubleFloat{T}, y::T) where {T<:AbstractFloat}
    signbit(y) ? -(abs(x)) : abs(x)
end
@inline function copysign(x::DoubleFloat{T}, y::DoubleFloat{T}) where {T<:AbstractFloat}
    signbit(y) ? -(abs(x)) : abs(x)
end


function frexp(x::DoubleFloat{T}) where {T<:AbstractFloat}
    frhi, exphi = frexp(HI(x))
    frlo, explo = frexp(LO(x))
    return (frhi, exphi), (frlo, explo)
end

function ldexp(x::DoubleFloat{T}, exponent::I) where {T, I<:Integer}
    return DoubleFloat(ldexp(HI(x), exponent), ldexp(LO(x), exponent))
end

function ldexp(dhi::Tuple{T,T}, dlo::Tuple{T,T}) where {T<:AbstractFloat}
    return DoubleFloat(ldexp(dhi[1], dhi[2]), ldexp(dlo[1], dlo[2]))
end

function exponent(x::DoubleFloat{T}) where {T<:AbstractFloat}
    ehi = exponent(HI(x))
    elo = exponent(LO(x))
    return ehi, elo
end

function significand(x::DoubleFloat{T}) where {T<:AbstractFloat}
    shi = significand(HI(x))
    slo = significand(LO(x))
    return shi, slo
end

function signs(x::DoubleFloat{T}) where {T<:AbstractFloat}
    shi = sign(HI(x))
    slo = sign(LO(x))
    return shi, slo
end


posulp(x::T) where {T<:Base.IEEEFloat} = significand(x) !== -one(T) ? eps(x) : eps(x)/2
negulp(x::T) where {T<:Base.IEEEFloat} = significand(x) !== one(T) ? -eps(x) : -eps(x)/2

function eps(x::DoubleFloat{T}) where {T<:AbstractFloat}
    return LO(x) !== zero(T) ? eps(LO(x)) : eps(posulp(HI(x)))
end

function ulp(x::DoubleFloat{T}) where {T<:AbstractFloat}
    return LO(x) !== zero(T) ? posulp(LO(x)) : posulp(posulp(HI(x)))
end

eps(::Type{D}) where {T<:AbstractFloat, D<:DoubleFloat{T}} = D(eps(posulp(one(T))))
ulp(::Type{D}) where {T<:AbstractFloat, D<:DoubleFloat{T}} = D(posulp(poslulp(one(T))))


function nextfloat(x::DoubleFloat{T}) where {T<:AbstractFloat}
    !isfinite(x) && return(x)
    if !iszero(LO(x))
        DoubleFloat{T}(HI(x)) + nextfloat(LO(x))
    else
        DoubleFloat{T}(HI(x), ulp(ulp(HI(x))))
    end
end

function prevfloat(x::DoubleFloat{T}) where {T<:AbstractFloat}
    !isfinite(x) && return(x)
    if !iszero(LO(x))
        DoubleFloat{T}(HI(x)) + prevfloat(LO(x))
    else
        DoubleFloat{T}(HI(x), -ulp(ulp(HI(x))))
    end
end

function nextfloat(x::DoubleFloat{T}, n::Int) where {T<:AbstractFloat}
    !isfinite(x) && return(x)
    if !iszero(LO(x))
        x + n*ulp(LO(x))
    else
        DoubleFloat{T}(HI(x), n*ulp(ulp(HI(x))))
    end
end

function prevfloat(x::DoubleFloat{T}, n::Int) where {T<:AbstractFloat}
    !isfinite(x) && return(x)
    if !iszero(LO(x))
        x - n*ulp(LO(x))
    else
        DoubleFloat{T}(HI(x), -n*ulp(ulp(HI(x))))
    end
end


@inline function intpart(x::Tuple{T,T}) where {T<:AbstractFloat}
    hi, lo = x
    ihi = modf(hi)[2]
    ilo = modf(lo)[2]
    return add_2(ihi, ilo)
end

@inline function fracpart(x::Tuple{T,T}) where {T<:AbstractFloat}
    hi, lo = x
    fhi = modf(hi)[1]
    flo = modf(lo)[1]
    return add_2(fhi, flo)
end

function intpart(x::DoubleFloat{T}) where {T<:AbstractFloat}
    ihi, ilo = intpart(HILO(x))
    return DoubleFloat(ihi, ilo)
end


function fracpart(x::DoubleFloat{T}) where {T<:AbstractFloat}
    fhi, flo = fracpart(HILO(x))
    return DoubleFloat(fhi, flo)
end

function modf(x::DoubleFloat{T}) where {T<:AbstractFloat}
    hi, lo = HILO(x)
    fhi, ihi = modf(hi)
    flo, ilo = modf(lo)
    ihi, ilo = add_2(ihi, ilo)
    fhi, flo = add_2(fhi, flo)
    i = DoubleFloat(ihi, ilo)
    f = DoubleFloat(fhi, flo)
    return f, i
end

function fmod(fpart::DoubleFloat{T}, ipart::DoubleFloat{T}) where {T<:AbstractFloat}
   return ipart + fpart
end

function fmod(parts::Tuple{DoubleFloat{T}, DoubleFloat{T}}) where {T<:AbstractFloat}
   return parts[1] + parts[2]
end
