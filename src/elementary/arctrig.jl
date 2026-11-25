for F in (:asin, :acos, :acsc, :asec, :acot)
    @eval begin
        Base.$F(x::Double64) = Double64Float128($F, x)
        Base.$F(x::Double32) = Double32Float128($F, x)
        Base.$F(x::Double16) = Double16Float128($F, x)
    end
end

# The dyadic centers reduce the argument to about ±1/32.
const _ATAN_DYADIC, _ATAN_LOCAL_COEFFS = setprecision(BigFloat, 256) do
    anchors = ntuple(i -> HILO(Double64(atan(BigFloat(i - 1) / 16))), 17)
    coeffs = ntuple(i -> HILO(Double64((-1)^i / BigFloat(2i + 1))), 9)
    anchors, coeffs
end

@inline function _atan_unit(a::Double64)
    return unsafe_double(Float64, _atan_unit_words(HILO(a)..., _ATAN_DYADIC, _ATAN_LOCAL_COEFFS, Val(5))...)
end

@inline function _atan_unit_words(h::T, l::T, anchors, coefficients, taper) where {T}
    k = unsafe_trunc(Int, round(16 * h))
    c = k * T(0.0625)
    numerator = two_hilo_sum_(h - c, l)
    denominator = add_dddd_dd_((one(T), zero(T)), mul_dddd_dd_((c, zero(T)), (h, l)))
    p = dvi_dddd_dd_(numerator, denominator)
    z = square_dd_dd_(p)
    correction = mul_dddd_dd_(mul_dddd_dd_(p, z), _tapered_poly(z, coefficients, taper))
    angle = add_dddd_dd_(p, correction)
    return add_dddd_dd_(angle, @inbounds(anchors[k + 1]))
end

function Base.atan(x::Double64)
    isnan(x) && return x
    abs(HI(x)) <= 0x1p-53 && return x
    isinf(x) && return copysign(halfpi, x)
    a = abs(x)
    if a > 1.0
        return copysign(halfpi - _atan_unit(inv(a)), x)
    end
    return copysign(_atan_unit(a), x)
end

Base.atan(x::Double16) = Double16(atan(Double64(x)))

Base.atan(y::Double64, x::Double64) = Double64(atan(Quadmath.Float128(y), Quadmath.Float128(x)))
Base.atan(y::Double32, x::Double32) = Double32(atan(Quadmath.Float128(y), Quadmath.Float128(x)))
Base.atan(y::Double16, x::Double16) = Double16(atan(Quadmath.Float128(y), Quadmath.Float128(x)))

_batch_kernel(::typeof(atan), ::Type{Double64}, ::Type{Double64}) =
    _BatchKernel(x -> _batch_bounded(x, 0.005, prevfloat(1.0)), _atan_unit)
