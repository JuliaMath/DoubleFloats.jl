# Quadmath conversions

@inline Quadmath.Float128(x::Double64) = Quadmath.Float128(x.hi) + x.lo
@inline Quadmath.Float128(x::Double32) = Quadmath.Float128(x.hi) + x.lo
@inline Quadmath.Float128(x::Double16) = Quadmath.Float128(x.hi) + Float32(x.lo)

@inline Quadmath.ComplexF128(x::ComplexDF64) = Quadmath.ComplexF128(Quadmath.Float128(real(x)), Quadmath.Float128(imag(x)))
@inline Quadmath.ComplexF128(x::ComplexDF32) = Quadmath.ComplexF128(Quadmath.Float128(real(x)), Quadmath.Float128(imag(x)))
@inline Quadmath.ComplexF128(x::ComplexDF16) = Quadmath.ComplexF128(Quadmath.Float128(real(x)), Quadmath.Float128(imag(x)))

@inline function Double64(x::Quadmath.Float128)
    hi = Float64(x)
    lo = Float64(x - hi)
    return Double64(hi,lo)
end
@inline function Double32(x::Quadmath.Float128)
    hi = Float32(x)
    lo = Float32(x - hi)
    return Double32(hi,lo)
end
@inline function Double16(x::Quadmath.Float128)
    hi = Float16(x)
    lo = Float16(x - hi)
    return Double16(hi,lo)
end

@inline ComplexDF64(x::Quadmath.ComplexF128) =
    ComplexDF64(Double64(real(x)), Double64(imag(x)))

@inline ComplexDF32(x::Quadmath.ComplexF128) =
    ComplexDF32(Double32(real(x)), Double32(imag(x)))

@inline ComplexDF16(x::Quadmath.ComplexF128) =
    ComplexDF16(Double16(real(x)), Double16(imag(x)))


@inline Double64Float128(fn::F, x::Double64) where {F<:Function} =
    Double64(fn(Quadmath.Float128(x)))

@inline Double32Float128(fn::F, x::Double32) where {F<:Function} =
    Double32(fn(Quadmath.Float128(x)))

@inline Double16Float128(fn::F, x::Double16) where {F<:Function} =
    Double16(fn(Quadmath.Float128(x)))


@inline ComplexDF64ComplexF128(fn::F, x::ComplexDF64) where {F<:Function} =
    ComplexDF64(fn(Quadmath.ComplexF128(x)))

@inline ComplexDF32ComplexF128(fn::F, x::ComplexDF32) where {F<:Function} =
    ComplexDF32(fn(Quadmath.ComplexF128(x)))

@inline ComplexDF16ComplexF128(fn::F, x::ComplexDF32) where {F<:Function} =
    ComplexDF16(fn(Quadmath.ComplexF128(x)))


convert(::Type{Quadmath.Float128}, x::Double64) = Quadmath.Float128(x)
convert(::Type{Quadmath.Float128}, x::Double32) = Quadmath.Float128(x)
convert(::Type{Quadmath.Float128}, x::Double16) = Quadmath.Float128(x)

convert(::Type{Double64}, x::Quadmath.Float128) = Double64(x)
convert(::Type{Double32}, x::Quadmath.Float128) = Double32(x)
convert(::Type{Double16}, x::Quadmath.Float128) = Double16(x)

promote_rule(::Type{Double64}, ::Type{Quadmath.Float128}) = Double64
promote_rule(::Type{Double32}, ::Type{Quadmath.Float128}) = Double32
promote_rule(::Type{Double16}, ::Type{Quadmath.Float128}) = Double16

# Complex

@inline Quadmath.ComplexF128(x::Double64) = Quadmath.ComplexF128(Quadmath.Float128(x))
@inline Quadmath.ComplexF128(x::Double32) = Quadmath.ComplexF128(Quadmath.Float128(x))
@inline Quadmath.ComplexF128(x::Double16) = Quadmath.ComplexF128(Quadmath.Float128(x))

@inline Double64(x::Quadmath.ComplexF128) = Double64(real(x))
@inline Double32(x::Quadmath.ComplexF128) = Double32(real(x))
@inline Double16(x::Quadmath.ComplexF128) = Double16(real(x))


convert(::Type{Quadmath.ComplexF128}, x::ComplexDF64) = Quadmath.ComplexF128(x)
convert(::Type{Quadmath.ComplexF128}, x::ComplexDF32) = Quadmath.ComplexF128(x)
convert(::Type{Quadmath.ComplexF128}, x::ComplexDF16) = Quadmath.ComplexF128(x)

convert(::Type{ComplexDF64}, x::Quadmath.ComplexF128) = ComplexDF64(x)
convert(::Type{ComplexDF32}, x::Quadmath.ComplexF128) = ComplexDF32(x)
convert(::Type{ComplexDF16}, x::Quadmath.ComplexF128) = ComplexDF16(x)

promote_rule(::Type{ComplexDF64}, ::Type{Quadmath.ComplexF128}) = ComplexDF64
promote_rule(::Type{ComplexDF32}, ::Type{Quadmath.ComplexF128}) = ComplexDF32
promote_rule(::Type{ComplexDF16}, ::Type{Quadmath.ComplexF128}) = ComplexDF16
