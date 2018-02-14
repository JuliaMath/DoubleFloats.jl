import Base: signbit, sign, abs, (-), flipsign, copysign, ldexp, frexp

@inline signbit(a::Double{T,E}) where {T,E} = signbit(HI(a))
@inline sign(a::Double{T,E}) where {T,E} = sign(HI(a))
@inline abs(a::Double{T,E}) where {T,E} = signbit(a) ? Double(E, -HI(a), -LO(a)) : a
@inline (-)(a::Double{T,E}) where {T,E} = Double(E, -HI(a), -LO(a))

@inline function flipsign(x::Double{T,E}, y::T) where {T<:Real, E<:Emphasis}
    signbit(y) ? -x : x
end
@inline function flipsign(x::Double{T,E}, y::Double{T,E}) where {T<:Real, E<:Emphasis}
    signbit(y) ? -x : x
end

@inline function copysign(x::Double{T,E}, y::T) where {T<:Real, E<:Emphasis}
    signbit(y) ? -(abs(x)) : abs(x)
end
@inline function copysign(x::Double{T,E}, y::Double{T,E}) where {T<:Real, E<:Emphasis}
    signbit(y) ? -(abs(x)) : abs(x)
end


function frexp(x::Double{T,E}) where {T<:Real, E<:Emphasis}
    frhi, exphi = frexp(HI(x))
    frlo, explo = frexp(LO(x))
    return (frhi, exphi), (frlo, explo), E
end

function ldexp(x::Double{T,E}, exponent::I) where {T,E,I<:Integer}
    return Double(E, ldexp(HI(x), exponent), ldexp(LO(x), exponent))
end

function ldexp(dhi::Tuple{T,T}, dlo::Tuple{T,T}, ::Type{E}) where {T<:Real, E<:Emphasis}
    return Double(E, ldexp(dhi[1], dhi[2]), ldexp(dlo[1], dlo[2]))
end
