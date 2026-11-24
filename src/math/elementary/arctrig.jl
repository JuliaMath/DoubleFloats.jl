for F in (:asin, :acos, :acsc, :asec, :acot)
    @eval begin
      $F(x::Double64) = Double64Float128($F, x)
      $F(x::Double32) = Double32Float128($F, x)
      $F(x::Double16) = Double16Float128($F, x)
    end
end

# atan is sufficiently common that routing every Double64 call through
# libquadmath dominates its cost (conversion, a foreign call, and conversion
# back).  Reduce to |r| <= tan(pi/16), halve once with
#     atan(r) = 2atan(r / (1 + sqrt(1 + r^2))),
# and evaluate the alternating Taylor series there.  The halved argument is
# below 0.1, so 21 terms leave more than 130 bits of truncation margin.
const _atan_pi8 = sqrt(Double64(2.0)) - 1.0
const _atan_tanpi16_hi = 0.1989123673796580
const _atan_tan3pi16_hi = 0.6681786379192989

@inline function _atan_small(x::Double64)
    y = x / (1.0 + sqrt(1.0 + square(x)))
    return _atan_poly(y, square(y), two_hilo_sum, *)
end

@inline function _atan_poly(y, z, sum::S, mul::M) where {S,M}
    zh = HI(z); zl = LO(z)
    # Q(z) = sum_{j>=1} (-1)^j z^(j-1)/(2j+1), atan(y) = y*(1 + z*Q(z)).
    # Coefficients must be double-double (a Float64-rounded 1/3 alone costs
    # ~2e-20 absolute); the Horner runs on zh with the lo word applied
    # through the Float64 derivative, as in log1p_small.  |z| <= 0.0097,
    # so truncating after 1/37 leaves ~2^-120 margin.
    ph = inv_oddint_f64[18]; pl = inv_oddint_lo[18]
    Base.Cartesian.@nexprs 17 k -> begin
        j = 18 - k
        s = iseven(j) ? 1.0 : -1.0
        ph, pl = _horner_step(s * inv_oddint_f64[j], s * inv_oddint_lo[j], zh, ph, pl)
    end
    qp = 9.0 * inv_oddint_f64[10]
    Base.Cartesian.@nexprs 8 k -> begin
        j = 10 - k
        s = iseven(j) ? 1.0 : -1.0
        qp = s * (j - 1) * inv_oddint_f64[j] + zh * qp
    end
    ph, pl = sum(ph, qp * zl + pl)
    th, tl = _horner_step(1.0, 0.0, zh, ph, pl)        # 1 + z*Q
    th, tl = sum(th, ph * zl + tl)
    return mul_by_two(mul(y, Double64(th, tl)))
end

function atan(x::Double64)
    isnan(x) && return x
    iszero(x) && return x
    isinf(x) && return copysign(halfpi, x)

    ax = abs(x)
    invert = ax > 1.0
    invert && (ax = inv(ax))
    if HI(ax) > _atan_tan3pi16_hi
        y = qrtrpi + _atan_small((ax - 1.0) / (ax + 1.0))
    elseif HI(ax) > _atan_tanpi16_hi
        y = mul_by_half(qrtrpi) + _atan_small((ax - _atan_pi8) / (1.0 + ax * _atan_pi8))
    else
        y = _atan_small(ax)
    end
    invert && (y = halfpi - y)
    return copysign(y, x)
end

atan(x::Double32) = Double32(atan(Double64(x)))
atan(x::Double16) = Double16(atan(Double64(x)))

atan(y::Double64, x::Double64) = Double64(atan(Quadmath.Float128(y), Quadmath.Float128(x)))
atan(y::Double32, x::Double32) = Double32(atan(Quadmath.Float128(y), Quadmath.Float128(x)))
atan(y::Double16, x::Double16) = Double16(atan(Quadmath.Float128(y), Quadmath.Float128(x)))

@inline function _batch_atan(x)
    y = _batch_div(x, _batch_add(1.0, _batch_sqrt(_batch_add(1.0, _batch_square(x)))))
    return _atan_poly(y, _batch_square(y), two_hilo_sum_, _batch_mul)
end

_batch_kernel(::typeof(atan), ::Type{Double64}, ::Type{Double64}) =
    _BatchKernel(x -> _batch_bounded(x, 0.005, 0.19), _batch_atan)
