# High-order terms stay in one word. The first double-word coefficient
# absorbs the tapered tail before the terms that need both words.
@inline function _tapered_poly(r, coefficients, ::Val{M}) where {M}
    tail = coefficients[end][1]
    for i in length(coefficients)-1:-1:M+1
        tail = fma(tail, r[1], coefficients[i][1])
    end
    p = _horner_step_dd(coefficients[M], tail, r)
    for i in M-1:-1:1
        p = _horner_step_dd(coefficients[i], p, r)
    end
    return p
end

const _EXP2_128, _EXP_FINE_COEFFS, _EXP2_FINE_COEFFS, _EXP_FINE_REDUCTION =
    setprecision(BigFloat, 256) do
        ln2 = log(BigFloat(2))
        step = ln2 / 128
        # A 32-bit head times any admitted index is exact in Float64.
        h = reinterpret(Float64, reinterpret(UInt64, Float64(step)) & (~UInt64(0) << 21))
        m = Float64(step - h)
        l = Float64(step - h - m)
        table = ntuple(i -> HILO(Double64(exp2(BigFloat(i - 1) / 128))), 128)
        natural = ntuple(i -> HILO(Double64(inv(BigFloat(factorial(big(i - 1)))))), 10)
        binary = ntuple(i -> HILO(Double64(ln2^(i - 1) / factorial(big(i - 1)))), 10)
        table, natural, binary, (Float64(inv(step)), h, m, l)
    end

# This guard keeps both the output head and its final scale normal
# and leaves headroom above the relative-accuracy floor at the low end.
@inline _exp_fine_range(h::Float64) = -670.0 <= h <= 700.0
@inline _exp2_fine_range(h::Float64) = -966.0 <= h <= 1023.0

@inline function _exp_fine(input)
    xh, xl = input
    inv_step, sh, sm, sl = _EXP_FINE_REDUCTION
    k = round(xh * inv_step)
    a = fma(-k, sh, xh)
    v, e = two_prod_(k, sm)
    q, w = two_sum_(a, -v)
    r, z = two_sum_(q, xl)
    return _exp_fine_reconstruct((r, ((w - e) + z) - k * sl), k, _EXP_FINE_COEFFS)
end

@inline function _exp2_fine(input)
    h, l = input
    k = round(128.0 * h)
    r = two_sum_(h - 0.0078125 * k, l)
    return _exp_fine_reconstruct(r, k, _EXP2_FINE_COEFFS)
end

@inline function _exp_fine_reconstruct(r, k, coefficients)
    i = unsafe_trunc(Int32, k)
    p = _tapered_poly(r, coefficients, Val(6))
    t = @inbounds _EXP2_128[(i & 127) + 1]
    h, l = mul_dddd_dd_(p, t)
    scale = _pow2(Float64, i >> 7)
    return h * scale, l * scale
end

const _LOG_FINE_COEFFS, _LOG2_FINE_COEFFS, _LOG_FINE_TABLE, _LOG2_FINE_TABLE =
    setprecision(BigFloat, 256) do
        ln2 = log(BigFloat(2))
        centers = ntuple(i -> 1 + BigFloat(2i - 1) / 256, 128)
        natural = ntuple(i -> HILO(Double64(BigFloat(2) / (2i - 1))), 11)
        binary = ntuple(i -> HILO(Double64(2 / ((2i - 1) * ln2))), 11)
        table = map(centers) do c
            # Store log(c/2) in the upper part of the binade. This
            # avoids subtracting a full log(2) from a near-one answer.
            lc = log(c >= 1.5 ? c / 2 : c)
            Float64(c), HILO(Double64(lc))
        end
        table2 = map(centers) do c
            lc = log2(c >= 1.5 ? c / 2 : c)
            Float64(c), HILO(Double64(lc))
        end
        natural, binary, table, table2
    end

# The wider log1p interval avoids losing low bits to the rounding of
# 1+x while the condition number of that addition is still significant.
const _LOG1P_WIDE_COEFFS = setprecision(BigFloat, 256) do
    ntuple(i -> HILO(Double64(BigFloat(2) / (2i - 1))), 14)
end

const _LOG_FINE_SHORT = ntuple(i -> _LOG_FINE_COEFFS[i], 6)
const _LOG2_FINE_SHORT = ntuple(i -> _LOG2_FINE_COEFFS[i], 6)

@inline _log_fine_range(h::Float64) = 0x1p-500 <= h <= 0x1p500
@inline _log_near_one(h::Float64) = 0.9375 < h < 1.0625

@inline function _log_fine(input, base)
    _log_near_one(input[1]) && return _log_fine_near(input, base, Val(false))
    return _log_fine_table(input, base)
end

@inline function _log_fine_near(input, ::Val{B}, ::Val{Batch}) where {B,Batch}
    h, l = input
    nh, nl = two_hilo_sum_(h - 1.0, l)
    tiny = abs(nh) <= 0x1p-104
    if !Batch && tiny
        return B ? mul_dddd_dd_((nh, nl), _log2_e(Float64)) : (nh, nl)
    end
    dh, dl = two_sum_(h, 1.0)
    v = _log_near_regular(nh, nl, dh, dl, l, B ? _LOG2_FINE_COEFFS : _LOG_FINE_COEFFS)
    if Batch
        small = B ? mul_dddd_dd_((nh, nl), _log2_e(Float64)) : (nh, nl)
        return ifelse(tiny, small[1], v[1]), ifelse(tiny, small[2], v[2])
    end
    return v
end

@inline function _log_fine_table(input, ::Val{B}) where {B}
    h, l = input
    ex = _raw_exponent(h)
    mh = _uldexp(h, -ex)
    ml = l * _pow2(Float64, -ex)
    j = Int((reinterpret(UInt64, mh) >> 45) & UInt64(127))
    c, anchor = @inbounds (B ? _LOG2_FINE_TABLE : _LOG_FINE_TABLE)[j + 1]
    # Sterbenz subtraction is exact. Normalize before _mf_div so its
    # leading quotient approximates the entire numerator.
    dh, dl = two_sum_(mh, c)
    t = _mf_div(two_hilo_sum_(mh - c, ml), (dh, dl + ml))
    v = mul_dddd_dd_(t, _tapered_poly(square_dd_dd_(t),
                       B ? _LOG2_FINE_SHORT : _LOG_FINE_SHORT, Val(3)))
    e = Float64(ex + (c >= 1.5))
    if B
        return add_dddd_dd_(add_dddd_dd_(anchor, (e, 0.0)), v)
    end
    a, b = _ln_2(Float64)
    p, q = two_prod_(e, a)
    return add_dddd_dd_(add_dddd_dd_(anchor, (p, fma(e, b, q))), v)
end

@inline function _log_near_regular(nh, nl, dh, dl, l, coefficients, taper=Val(5))
    dl, dt = two_sum_(dl, l)
    reciprocal = inv(dh)
    qh = nh * reciprocal
    a = fma(-qh, dh, nh)
    b = fma(-qh, dl, nl)
    s, e = two_sum_(a, b)
    ql = s * reciprocal
    r = fma(-ql, dh, s) + e
    tail = fma(-qh, dt, fma(-ql, dl, r)) * reciprocal
    t = two_hilo_sum_(qh, ql + tail)
    p = _tapered_poly(square_dd_dd_(t), coefficients, taper)
    return mul_dddd_dd_(t, p)
end

@inline function _log1p_near(x::Double64)
    h, l = HILO(x)
    abs(h) <= 0x1p-104 && return x
    dh, dl = two_sum_(h, 2.0)
    if abs(h) < 0.0625
        return Double64(_log_near_regular(h, l, dh, dl, l, _LOG_FINE_COEFFS)...)
    end
    return Double64(_log_near_regular(h, l, dh, dl, l, _LOG1P_WIDE_COEFFS, Val(7))...)
end
