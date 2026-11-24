for F in (:asin, :acos, :acsc, :asec, :acot)
    @eval begin
      $F(x::Double64) = Double64Float128($F, x)
      $F(x::Double32) = Double32Float128($F, x)
      $F(x::Double16) = Double16Float128($F, x)
    end
end

# The dyadic centers reduce the argument to about ±1/32.
const _ATAN_DYADIC, _ATAN_LOCAL_COEFFS = setprecision(BigFloat, 256) do
    anchors = ntuple(i -> Double64(atan(BigFloat(i - 1) / 16)), 17)
    coeffs = ntuple(i -> HILO(Double64((-1)^i / BigFloat(2i + 1))), 9)
    anchors, coeffs
end

@inline function _atan_unit(a::Double64)
    k = unsafe_trunc(Int, round(16 * HI(a)))
    c = k * 0.0625
    h, l = HILO(a)
    numerator = two_hilo_sum_(h - c, l)
    denominator = add_dddd_dd_((1.0, 0.0), mul_dddd_dd_((c, 0.0), (h, l)))
    p = dvi_dddd_dd_(numerator, denominator)
    z = square_dd_dd_(p)
    correction = mul_dddd_dd_(mul_dddd_dd_(p, z), _tapered_poly(z, _ATAN_LOCAL_COEFFS, Val(5)))
    angle = add_dddd_dd_(p, correction)
    return Double64(add_dddd_dd_(angle, HILO(@inbounds _ATAN_DYADIC[k + 1]))...)
end

function atan(x::Double64)
    isnan(x) && return x
    abs(HI(x)) <= 0x1p-53 && return x
    isinf(x) && return copysign(halfpi, x)
    a = abs(x)
    if a > 1.0
        return copysign(halfpi - _atan_unit(inv(a)), x)
    end
    return copysign(_atan_unit(a), x)
end

atan(x::Double32) = Double32(atan(Double64(x)))
atan(x::Double16) = Double16(atan(Double64(x)))

atan(y::Double64, x::Double64) = Double64(atan(Quadmath.Float128(y), Quadmath.Float128(x)))
atan(y::Double32, x::Double32) = Double32(atan(Quadmath.Float128(y), Quadmath.Float128(x)))
atan(y::Double16, x::Double16) = Double16(atan(Quadmath.Float128(y), Quadmath.Float128(x)))

_batch_kernel(::typeof(atan), ::Type{Double64}, ::Type{Double64}) =
    _BatchKernel(x -> _batch_bounded(x, 0.005, prevfloat(1.0)), _atan_unit)
