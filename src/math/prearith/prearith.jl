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


@inline function flipsign(x::DoubleFloat{T}, y::F) where {T<:IEEEFloat, F<:Union{AbstractFloat, Signed}}
    signbit(y) ? -x : x
end
@inline function copysign(x::DoubleFloat{T}, y::F) where {T<:IEEEFloat, F<:Union{AbstractFloat, Signed}}
    signbit(y) ? -abs(x) : abs(x)
end

flipsign(x::DoubleFloat{T}, y::U) where {T<:AbstractFloat, U<:Unsigned} = +x
copysign(x::DoubleFloat{T}, y::U) where {T<:AbstractFloat, U<:Unsigned} = +x

function Base.Math.frexp(x::DoubleFloat{T}) where {T<:IEEEFloat}
    frhi, exphi = frexp(HI(x))
    frlo, explo = frexp(LO(x))
    return (frhi, exphi), (frlo, explo)
end

function Base.Math.ldexp(x::DoubleFloat{T}, exponent::I) where {T<:IEEEFloat, I<:Integer}
    return DoubleFloat(ldexp(HI(x), exponent), ldexp(LO(x), exponent))
end

function Base.Math.ldexp(dhi::Tuple{T,I}, dlo::Tuple{T,I}) where {T<:IEEEFloat, I<:Integer}
    return DoubleFloat(ldexp(dhi[1], dhi[2]), ldexp(dlo[1], dlo[2]))
end

function Base.Math.ldexp(dhilo::Tuple{Tuple{T,I}, Tuple{T,I}}) where {T<:IEEEFloat, I<:Integer}
    return ldexp(dhilo[1], dhilo[2])
end

function exponent(x::DoubleFloat{T}) where {T<:IEEEFloat}
    ehi = Base.exponent(HI(x))
    elo = Base.exponent(LO(x))
    return ehi, elo
end

function significand(x::DoubleFloat{T}) where {T<:IEEEFloat}
    shi = Base.significand(HI(x))
    slo = Base.significand(LO(x))
    return shi, slo
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

function Base.Math.eps(x::DoubleFloat{T}) where {T<:IEEEFloat}
    return LO(x) !== zero(T) ? eps(LO(x)) : eps(posulp(HI(x)))
end

function ulp(x::DoubleFloat{T}) where {T<:IEEEFloat}
    return LO(x) !== zero(T) ? posulp(LO(x)) : posulp(posulp(HI(x)))
end

Base.Math.eps(::Type{D}) where {T<:AbstractFloat, D<:DoubleFloat{T}} = D(eps(posulp(one(T))))
ulp(::Type{D}) where {T<:AbstractFloat, D<:DoubleFloat{T}} = D(posulp(poslulp(one(T))))


function Base.Math.nextfloat(x::DoubleFloat{T}) where {T<:IEEEFloat}
    !isfinite(x) && return(x)
    if !iszero(LO(x))
        DoubleFloat{T}(HI(x)) + nextfloat(LO(x))
    else
        DoubleFloat{T}(HI(x), ulp(ulp(HI(x))))
    end
end

function Base.Math.prevfloat(x::DoubleFloat{T}) where {T<:IEEEFloat}
    !isfinite(x) && return(x)
    if !iszero(LO(x))
        DoubleFloat{T}(HI(x)) + prevfloat(LO(x))
    else
        DoubleFloat{T}(HI(x), -ulp(ulp(HI(x))))
    end
end

function Base.Math.nextfloat(x::DoubleFloat{T}, n::Int) where {T<:IEEEFloat}
    !isfinite(x) && return(x)
    if !iszero(LO(x))
        x + n*ulp(LO(x))
    else
        DoubleFloat{T}(HI(x), n*ulp(ulp(HI(x))))
    end
end

function Base.Math.prevfloat(x::DoubleFloat{T}, n::Int) where {T<:IEEEFloat}
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
    return DoubleFloat(ihi, ilo)
end


function fracpart(x::DoubleFloat{T}) where {T<:IEEEFloat}
    fhi, flo = fracpart(HILO(x))
    return DoubleFloat(fhi, flo)
end

function modf(x::DoubleFloat{T}) where {T<:IEEEFloat}
    hi, lo = HILO(x)
    fhi, ihi = modf(hi)
    flo, ilo = modf(lo)
    ihi, ilo = two_sum(ihi, ilo)
    fhi, flo = two_sum(fhi, flo)
    i = DoubleFloat(ihi, ilo)
    f = DoubleFloat(fhi, flo)
    return f, i
end

function fmod(fpart::DoubleFloat{T}, ipart::DoubleFloat{T}) where {T<:IEEEFloat}
   return ipart + fpart
end

function fmod(parts::Tuple{DoubleFloat{T}, DoubleFloat{T}}) where {T<:IEEEFloat}
   return parts[1] + parts[2]
end
