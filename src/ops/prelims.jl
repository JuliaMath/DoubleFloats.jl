import Base: signbit, sign, abs, (-), flipsign, copysign,
             ldexp, frexp, exponent, significand

@inline signbit(a::Double{T,E}) where {T,E} = signbit(HI(a))
@inline sign(a::Double{T,E}) where {T,E} = sign(HI(a))

@inline function (-)(a::Double{T,E}) where {T,E}
    if iszero(LO(a))
        Double(E, -HI(a), LO(a))
    else
        Double(E, -HI(a), -LO(a))
    end
end

@inline function abs(a::Double{T,E}) where {T,E}
    if HI(a) >= 0.0
        a
    else # HI(a) < 0.0
        -a
    end
end


@inline function flipsign(x::Double{T,E}, y::T) where {T<:AbstractFloat, E<:Emphasis}
    signbit(y) ? -x : x
end
@inline function flipsign(x::Double{T,E}, y::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
    signbit(y) ? -x : x
end

@inline function copysign(x::Double{T,E}, y::T) where {T<:AbstractFloat, E<:Emphasis}
    signbit(y) ? -(abs(x)) : abs(x)
end
@inline function copysign(x::Double{T,E}, y::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
    signbit(y) ? -(abs(x)) : abs(x)
end


function frexp(x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
    frhi, exphi = frexp(HI(x))
    frlo, explo = frexp(LO(x))
    return (frhi, exphi), (frlo, explo), E
end

function ldexp(x::Double{T,E}, exponent::I) where {T,E,I<:Integer}
    return Double(E, ldexp(HI(x), exponent), ldexp(LO(x), exponent))
end

function ldexp(dhi::Tuple{T,I}, dlo::Tuple{T,I}, ::Type{E}) where {I<:Signed, T<:AbstractFloat, E<:Emphasis}
    return Double(E, ldexp(dhi[1], dhi[2]), ldexp(dlo[1], dlo[2]))
end

ldexp(x::Tuple{Tuple{T,I}, Tuple{T,I}, ::Type{E}}) where {I<:Signed, T<:AbstractFloat, E<:Emphasis} =
    ldexp(x[1], x[2], x[3])
function exponent(x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
    ehi = exponent(HI(x))
    elo = exponent(LO(x))
    return ehi, elo
end

function significand(x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
    shi = significand(HI(x))
    slo = significand(LO(x))
    return shi, slo
end

function signs(x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
    shi = sign(HI(x))
    slo = sign(LO(x))
    return shi, slo
end

function nextfloat(x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
    !isfinite(x) && return(x)
    signbit(x) && return -prevfloat(-x)
    iszero(LO(x)) && return Double(E, HI(x), eps(HI(x))*0.5)
    signbit(LO(x)) && return Double(HI(x), -nextfloat(-LO(x)))
    return Double(HI(x), nextfloat(LO(x)))
end
function prevfloat(x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
    !isfinite(x) && return(x)
    signbit(x) && return -nextfloat(-x)
    iszero(LO(x)) && return Double(E, HI(x), -eps(HI(x))*0.5)
    signbit(LO(x)) && return Double(HI(x), -prevfloat(-LO(x)))
    return Double(HI(x), prevfloat(LO(x)))
end

function prevfloat(x::Double{T,E}, n::Int) where {T<:AbstractFloat, E<:Emphasis}
     return nextfloat(x, -n)
end
function nextfloat(x::Double{T,E}, n::Int) where {T<:AbstractFloat, E<:Emphasis}
    !isfinite(x) && return(x)
    signbit(x) && return -nextfloat(-x, n)
    iszero(LO(x)) && return Double(E, HI(x), n*eps(HI(x))*0.5)
    signbit(LO(x)) && return Double(HI(x), -nextfloat(-LO(x),n))
    return Double(HI(x), nextfloat(LO(x),n))
end
