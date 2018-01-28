import Base: signbit, sign, abs, :(-), flipsign, copysign, ldexp, frexp

@inline signbit(a::Double{T,E}) where {T,E} = signbit(a.hi)
@inline sign(a::Double{T,E}) where {T,E} = sign(a.hi)
@inline abs(a::Double{T,E}) where {T,E} = signbit(a) ? Double(E, -a.hi, -a.lo) : a
@inline (-)(a::Double{T,E}) where {T,E} = Double(E, -a.hi, -a.lo)

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

function ldexp(x::Double{T,E}, exponent::I) where {T,E,I<:Integer}
    return Double(E, ldexp(hi(x), exponent), ldexp(lo(x), exponent))
end

function frexp(::Type{E}, x::Double{T,E}) where {T<:Real, E<:Emphasis}
    frhi, exphi = frexp(hi(x))
    frlo, explo = frexp(lo(x))
    return E, frhi, exphi, frlo, explo
end

function ldexp(::Type{E}, frhi::T, exphi::I, frlo::T, explo::I) where {T<:Real, I<:Integer, E<:Emphasis}
    zhi = ldexp(frhi, exphi)
    zlo = ldexp(frlo, explo)
    return Double(E, zhi, zlo)
end

function frexp(x::Double{T,E}) where {T,E}
    frhi, exphi = frexp(hi(x))
    frlo, explo = frexp(lo(x))
    return frhi, exphi, frlo, explo
end

function ldexp(frhi::T, exphi::I, frlo::T, explo::I) where {T<:Real, I<:Integer}
    zhi = ldexp(frhi, exphi)
    zlo = ldexp(frlo, explo)
    return Double(EMPHASIS, zhi, zlo)
end
