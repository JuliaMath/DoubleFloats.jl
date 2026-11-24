const twopi  = Double64(6.283185307179586, 2.4492935982947064e-16)
const onepi  = Double64(3.141592653589793, 1.2246467991473532e-16)
const halfpi = Double64(1.5707963267948966, 6.123233995736766e-17)
const qrtrpi = Double64(0.7853981633974483, 3.061616997868383e-17)
const sixteenthpi = Double64(0.19634954084936207, 7.654042494670958e-18)
const _trig_taylor_cutoff = 0.09817477042468103
const thirtysecondpi = Double64(_trig_taylor_cutoff, 3.827021247335479e-18)
const threesixteenthpi = Double64(0.5890486225480862, 2.296212748401287e-17)

atanxy(x::T, y::T) where {T<:Real} = atan(y, x)

#=
     sin(a) from the Taylor series.
     Assumes |a| <= pi/32.
=#
# sin(a) = a*S(a^2), S(y) = 1 - y/3! + y^2/5! - ...
# cos(a) = C(a^2),   C(y) = 1 - y/2! + y^2/4! - ...
const sinS = (Double64(1.0, 0.0),
              ntuple(k -> (iseven(k) ? inv_fact[2k+1] : -inv_fact[2k+1]), 8)...)
const cosC = (Double64(1.0, 0.0),
              ntuple(k -> (iseven(k) ? inv_fact[2k] : -inv_fact[2k]), 9)...)
const sinS_h = map(x -> HI(x), sinS); const sinS_l = map(x -> LO(x), sinS)
const cosC_h = map(x -> HI(x), cosC); const cosC_l = map(x -> LO(x), cosC)

# The Horner recurrences multiply by the *Float64* hi word of y = a^2 only;
# the lo words enter once each, to first order:
#   y's lo through the derivatives S'(yh), C'(yh) (Float64 accuracy suffices)
#   a's lo through sin(ah + al) = sin(ah) + cos(ah)*al + O(al^2), etc.
@inline _sincos_taylor_core(ah::Float64, al::Float64) =
    _sincos_taylor_core(ah, al, two_hilo_sum, two_prod)

@inline function _sincos_taylor_core(ah::Float64, al::Float64, sum::S, prod::P) where {S,P}
    yh = ah * ah
    yl = fma(ah, ah, -yh)
    Sh = sinS_h[9]; Sl = sinS_l[9]
    for k in 8:-1:1
        Sh, Sl = DoubleFloats._horner_step(sinS_h[k], sinS_l[k], yh, Sh, Sl)
    end
    Ch = cosC_h[10]; Cl = cosC_l[10]
    for k in 9:-1:1
        Ch, Cl = DoubleFloats._horner_step(cosC_h[k], cosC_l[k], yh, Ch, Cl)
    end
    Sp = -0.16666666666666666 + yh*(0.016666666666666666 +
          yh*(-0.0005952380952380953 + yh*1.1022927689594356e-5))
    Cp = -0.5 + yh*(0.08333333333333333 +
          yh*(-0.004166666666666667 + yh*9.920634920634921e-5))
    Sh, Sl = sum(Sh, Sp * yl + Sl)
    Ch, Cl = sum(Ch, Cp * yl + Cl)
    sh, sl = prod(Sh, ah)                        # sin(ah) = ah*S
    sl = fma(Sl, ah, sl)
    sh, sl = sum(sh, sl)
    # cross corrections for a's lo word use the already-computed hi words,
    # which carry cos(ah) and sin(ah) to well past Float64 accuracy
    s1, e1 = sum(sh, Ch * al)
    c1, e2 = sum(Ch, -sh * al)
    return DoubleFloat{Float64}(sum(s1, sl + e1)...),
           DoubleFloat{Float64}(sum(c1, Cl + e2)...)
end

function sin_taylor(a::Double64)
    iszero(a) && return a
    return _sincos_taylor_core(HI(a), LO(a))[1]
end

function cos_taylor(a::Double64)
    iszero(a) && return one(Double64)
    return _sincos_taylor_core(HI(a), LO(a))[2]
end

function sincos_taylor(a::Double64)
    iszero(a) && return a, one(Double64)
    return _sincos_taylor_core(HI(a), LO(a))
end

function index_npio32(x::DoubleFloat{T}) where {T<:IEEEFloat}
    x < npio32[1] && return 1
    x >= npio32[end] && return length(npio32)
    result = 1
    while x >= npio32[result]
        result += 1
    end
    return max(1,result-1)
end


#=
   sin(a+b) = sin(a)*cos(b) + cos(a)*sin(b)
   cos(a+b) = cos(a)*cos(b) - sin(a)*sin(b)
=#



@inline function sin_circle(x::DoubleFloat{T}) where {T<:IEEEFloat}
    idx = index_npio32(x)
    pipart = npio32[idx]
    rest = x - pipart
    sin_part = sin_npio32[idx]
    cos_part = cos_npio32[idx]
    sin_rest, cos_rest = sincos_taylor(rest)
    result1 = sin_part * cos_rest
    result2 = cos_part * sin_rest
    result  = result1 + result2
    return result
end

@inline function cos_circle(x::DoubleFloat{T}) where {T<:IEEEFloat}
    idx = index_npio32(x)
    pipart = npio32[idx]
    rest = x - pipart
    sin_part = sin_npio32[idx]
    cos_part = cos_npio32[idx]
    sin_rest, cos_rest = sincos_taylor(rest)
    result1 = cos_part * cos_rest
    result2 = sin_part * sin_rest
    result  = result1 - result2
    return result
end


@inline function sincos_circle(x::DoubleFloat{T}) where {T<:IEEEFloat}
    idx = index_npio32(x)
    pipart = npio32[idx]
    rest = x - pipart
    sin_part = sin_npio32[idx]
    cos_part = cos_npio32[idx]
    sin_rest, cos_rest = sincos_taylor(rest)
    s = sin_part * cos_rest + cos_part * sin_rest
    c = cos_part * cos_rest - sin_part * sin_rest
    return s, c
end

@inline function tan_circle(x::DoubleFloat{T}) where {T<:IEEEFloat}
    idx = index_npio32(x)
    pipart = npio32[idx]
    rest = x - pipart
    sin_part = sin_npio32[idx]
    cos_part = cos_npio32[idx]
    sin_rest, cos_rest = sincos_taylor(rest)
    sin_result1 = sin_part * cos_rest
    sin_result2 = cos_part * sin_rest
    sin_result  = sin_result1 + sin_result2
    cos_result1 = cos_part * cos_rest
    cos_result2 = sin_part * sin_rest
    cos_result  = cos_result1 - cos_result2
    return sin_result / cos_result
end

@inline function sin_kernel(x::DoubleFloat{T}) where {T<:IEEEFloat}
    signbit(x) && return -sin(abs(x))
    iszero(x) && return zero(typeof(x))
    !isfinite(x) && return nan(typeof(x))
    if x >= twopi
       x = mod2pi(x)
    end
    if x >= onepi
       z = -sin_circle(x_minus_onepi(x))
    elseif T === Float64 && x >= onepi - thirtysecondpi
       # Near π, retain the third component of π during reduction.  The
       # circle reconstruction otherwise subtracts nearly equal terms.
       z = -sin_taylor(x_minus_onepi(x))
    elseif x >= halfpi
       z = cos_circle(x_minus_halfpi(x))
    elseif x <= thirtysecondpi
       z = sin_taylor(x)
    else
       z = sin_circle(x)
    end
    return z
end

@inline function cos_kernel(x::DoubleFloat{T}) where {T<:IEEEFloat}
    signbit(x) && return cos(abs(x))
    iszero(x) && return one(typeof(x))
    !isfinite(x) && return nan(typeof(x))
    if x >= twopi
       x = mod2pi(x)
    end
    if x >= onepi
       z = -cos_circle(x_minus_onepi(x))
    elseif T === Float64 && halfpi - thirtysecondpi <= x <= halfpi + thirtysecondpi
       # cos(π/2 + r) = -sin(r); use the triple-double π/2 reduction on
       # both sides of the root to avoid cancellation in cos_circle.
       # NB: the window must be bounded above; sin_taylor is only accurate
       # for |r| <= π/32, and everything in (π/2 + π/32, π) belongs to the
       # sin_circle branch below
       z = -sin_taylor(x_minus_halfpi(x))
    elseif x >= halfpi
       z = -sin_circle(x_minus_halfpi(x))
    elseif x <= thirtysecondpi
       z = cos_taylor(x)
    else
       z = cos_circle(x)
    end
    return z
end

@inline _trig_quadrant_value(h) = h * 0.6366197723675814 + 0.5

# sin and cos of w for |w| <= π/4 + eps
@inline function sincos_quadrant(w::DoubleFloat{T}) where {T<:IEEEFloat}
    if abs(HI(w)) <= _trig_taylor_cutoff         # π/32: direct Taylor pair
        return sincos_taylor(w)
    elseif signbit(HI(w))
        s, c = sincos_circle(-w)
        return -s, c
    end
    return sincos_circle(w)
end

# sin and cos together; assumes 0 <= x < 6.28125.
# One reduction by the *nearest* multiple of π/2, carried as a
# triple-double, keeps full relative accuracy near every root of sin and
# cos.  (Folding twice -- x-π then -π/2 -- would round the intermediate
# to two words and destroy the small remainder.)
@inline function sincos_kernel(x::DoubleFloat{T}) where {T<:IEEEFloat}
    !isfinite(x) && return nan(typeof(x)), nan(typeof(x))
    q = unsafe_trunc(Int, _trig_quadrant_value(HI(x)))   # round(x/(π/2))
    if q == 0
        return sincos_quadrant(x)
    elseif q == 1
        s, c = sincos_quadrant(x_minus_halfpi(x))
        return c, -s
    elseif q == 2
        s, c = sincos_quadrant(x_minus_onepi(x))
        return -s, -c
    elseif q == 3
        s, c = sincos_quadrant(x_minus_threehalfpi(x))
        return -c, s
    end
    s, c = sincos_quadrant(x_minus_twopi(x))
    return s, c
end

function cos(x::DoubleFloat{T}) where {T<:IEEEFloat}
    isnan(x) && return x
    isinf(x) && throw(DomainError("cos(x) only defined for finite x"))
    if T === Float64 && abs(x.hi) < 6.28125
        ax = abs(x)
        HI(ax) <= _trig_taylor_cutoff && return cos_taylor(ax)
        return sincos_kernel(ax)[2]
    end
    return abs(x.hi) < 6.28125 ? cos_kernel(x) : DoubleFloat{T}(cos(Quadmath.Float128(x)))
end

function sin(x::DoubleFloat{T}) where {T<:IEEEFloat}
    isnan(x) && return x
    isinf(x) && throw(DomainError("sin(x) only defined for finite x"))
    if T === Float64 && abs(x.hi) < 6.28125
        HI(abs(x)) <= _trig_taylor_cutoff && return sin_taylor(x)
        s = sincos_kernel(abs(x))[1]
        return signbit(x) ? -s : s
    end
    return abs(x.hi) < 6.28125 ? sin_kernel(x) : DoubleFloat{T}(sin(Quadmath.Float128(x)))
end

function tan(x::Double64)
    isnan(x) && return x
    isinf(x) && throw(DomainError("tan(x) only defined for finite x"))
    if abs(HI(x)) < 6.28125
        # the π-fraction reductions keep full relative accuracy near the
        # roots of sin and cos, so the quotient is relatively accurate
        # everywhere.  Close to the poles, though, |tan| is large and its
        # *absolute* error grows with it; Float128's quad-precision
        # reduction does ~500x better there, so give the pole band to it.
        s, c = sincos_kernel(abs(x))
        abs(HI(c)) < 0.1 && return Double64(tan(Float128(x)))
        t = s / c
        return signbit(x) ? -t : t
    end
    return Double64(tan(Float128(x)))
end

function cot(x::DoubleFloat{T}) where {T<:IEEEFloat}
    isnan(x) && return x
    isinf(x) && throw(DomainError("cot(x) only defined for finite x"))
    abs(mod1pi(x)) <= eps(one(DoubleFloat{T})) && return DoubleFloat{T}(Inf)
    return inv(tan(x))
end

function sinpi(x::DoubleFloat{T}) where {T<:IEEEFloat}
    isnan(x) && return x
    isinf(x) && throw(DomainError("sinpi(x) only defined for finite x"))
    return DoubleFloat{T}(sinpi(Quadmath.Float128(x)))
end

function cospi(x::DoubleFloat{T}) where {T<:IEEEFloat}
    isnan(x) && return x
    isinf(x) && throw(DomainError("cospi(x) only defined for finite x"))
    return DoubleFloat{T}(cospi(Quadmath.Float128(x)))
end

function tanpi(x::DoubleFloat{T}) where {T<:IEEEFloat}
    isnan(x) && return x
    isinf(x) && throw(DomainError("tanpi(x) only defined for finite x"))
    return sinpi(x)/cospi(x)
end

function sincos(x::DoubleFloat{T}) where {T<:IEEEFloat}
    isnan(x) && return x, x
    isinf(x) && throw(DomainError("sincos(x) only defined for finite x"))
    if T === Float64 && abs(x.hi) < 6.28125
        if signbit(x)
            s, c = sincos_kernel(-x)
            return -s, c
        end
        return sincos_kernel(x)
    end
    return sin(x), cos(x)
end                    

function sincospi(x::DoubleFloat{T}) where {T<:IEEEFloat}
    isnan(x) && return x
    isinf(x) && throw(DomainError("sincospi(x) only defined for finite x"))
    return sinpi(x), cospi(x)
end                    

function cis(x::DoubleFloat{T}) where {T<:IEEEFloat}
    isnan(x) && return x
    isinf(x) && throw(DomainError("cis(x) only defined for finite x"))
    return cos(x) + im*sin(x)
end

function cispi(x::DoubleFloat{T}) where {T<:IEEEFloat}
    isnan(x) && return x
    isinf(x) && throw(DomainError("cis(x) only defined for finite x"))
    return cospi(x) + im*sinpi(x)
end

# The small-angle bands reach the Taylor pair directly. Cosine stays
# above 0.99. The positive cotangent band is far from the mod1pi cutoff.
@inline _batch_trig_range(x) = _batch_bounded(x, 0.005, 0.09)
@inline _batch_signed_trig_range(x) = _batch_trig_range(x) | _batch_bounded(x, -0.09, -0.005)
@inline _batch_sincos(x) = _sincos_taylor_core(HILO(x)..., two_hilo_sum_, two_prod_)
@inline _batch_sin(x) = first(_batch_sincos(x))
@inline _batch_cos(x) = last(_batch_sincos(x))
@inline _batch_cos_signed(x) = _batch_cos(_batch_abs(x))

@inline function _batch_sincos_signed(x)
    s, c = _batch_sincos(_batch_abs(x))
    return ifelse(signbit(x), _batch_neg(s), s), c
end

@inline function _batch_cis(x)
    s = _batch_sin(x)
    c = _batch_cos_signed(x)
    return ComplexDF64(_batch_add(c, zero(Double64)), s)
end

@inline function _batch_tan(x)
    s, c = _batch_sincos(x)
    return _batch_div(s, c)
end

@inline function _batch_tan_signed(x)
    t = _batch_tan(_batch_abs(x))
    return ifelse(signbit(x), _batch_neg(t), t)
end

@inline _batch_cot(x) = _batch_inv(_batch_tan(x))

for (scalar, kernel, result) in ((sin, _batch_sin, Double64), (cos, _batch_cos_signed, Double64),
        (tan, _batch_tan_signed, Double64), (cot, _batch_cot, Double64),
        (sincos, _batch_sincos_signed, Tuple{Double64,Double64}), (cis, _batch_cis, ComplexDF64))
    @eval _batch_kernel(::typeof($scalar), ::Type{$result}, ::Type{Double64}) =
        _batch_trig_kernel($scalar, $kernel)
end

_batch_trig_kernel(f, kernel) = _BatchKernel(_batch_signed_trig_range, kernel)
_batch_trig_kernel(::typeof(cot), kernel) = _BatchKernel(_batch_trig_range, kernel)

@inline function _batch_circle_range(x)
    return _batch_abs_bounded(x, 0.005, prevfloat(6.28125))
end

@inline function _batch_circle_tan_range(x)
    h = abs(HI(x))
    # A distance of 0.11 from either pole leaves ample margin over the
    # scalar cosine-head cutoff, including the low limb and rounding.
    return _batch_circle_range(x) & (abs(h - _trig_halfpi[1]) > 0.11) &
           (abs(h - _trig_threehalfpi[1]) > 0.11)
end

@inline function _batch_trig_quadrant(a)
    q = unsafe_trunc(Int32, _trig_quadrant_value(HI(a)))
    c = ifelse(q == 1, _trig_halfpi,
         ifelse(q == 2, _trig_pi,
         ifelse(q == 3, _trig_threehalfpi, _trig_twopi)))
    w = _trig_subtract(HI(a), LO(a), c, two_diff_, two_sum_)
    return q, ifelse(q == 0, a, w)
end

@inline function _batch_trig_sector(a)
    # The reduced angle lies in [0, π/4] up to rounding of the quadrant
    # selector. The head estimate can differ from the scalar table search
    # by one at an anchor. Resolve that ambiguity with both limbs.
    i = clamp(unsafe_trunc(Int32, HI(a) * 10.185916357881302), Int32(0), Int32(8)) + Int32(1)
    @inbounds return ifelse(_batch_positive_less(a, npio32[i]), max(Int32(1), i - Int32(1)),
                     ifelse(_batch_positive_less(a, npio32[i + Int32(1)]), i, i + Int32(1)))
end

@inline function _batch_circle_pair(x, signed_direct::Bool)
    ax = _batch_abs(x)
    q, w = _batch_trig_quadrant(ax)
    # The unpaired scalar sin uses the original signed input only for
    # the direct Taylor route at the origin.
    signed = signed_direct & (HI(ax) <= _trig_taylor_cutoff) & signbit(x)
    w = ifelse(signed, x, w)
    direct = abs(HI(w)) <= _trig_taylor_cutoff
    a = _batch_abs(w)
    i = _batch_trig_sector(a)
    @inbounds r = ifelse(direct, w, _batch_sub(a, npio32[i]))
    s, c = _batch_sincos(r)
    z = iszero(HI(r))
    s = ifelse(z, r, s)
    c = ifelse(z, one(Double64), c)
    @inbounds u, v = sin_npio32[i], cos_npio32[i]
    ts = _batch_add(_batch_mul(u, c), _batch_mul(v, s))
    tc = _batch_sub(_batch_mul(v, c), _batch_mul(u, s))
    s = ifelse(direct, s, ifelse(signbit(w), _batch_neg(ts), ts))
    c = ifelse(direct, c, tc)

    sine, cosine = ifelse(isodd(q), c, s), ifelse(isodd(q), s, c)
    flip_sine = ((q == 2) | (q == 3)) ⊻ (signbit(x) & !signed)
    flip_cosine = (q == 1) | (q == 2)
    return ifelse(flip_sine, _batch_neg(sine), sine),
           ifelse(flip_cosine, _batch_neg(cosine), cosine)
end

@inline _batch_circle_sincos(x) = _batch_circle_pair(x, false)
@inline _batch_circle_sin(x) = first(_batch_circle_pair(x, true))
@inline _batch_circle_cos(x) = last(_batch_circle_pair(_batch_abs(x), false))
@inline function _batch_circle_tan(x)
    s, c = _batch_circle_pair(_batch_abs(x), false)
    t = _batch_div(s, c)
    return ifelse(signbit(x), _batch_neg(t), t)
end

_batch_trig_kernel(::typeof(sincos), kernel) =
    _BatchAlternatives(_BatchKernel(_batch_signed_trig_range, kernel),
                       _BatchKernel(_batch_circle_range, _batch_circle_sincos))

for (f, p, k) in ((sin, _batch_circle_range, _batch_circle_sin),
                  (cos, _batch_circle_range, _batch_circle_cos),
                  (tan, _batch_circle_tan_range, _batch_circle_tan))
    @eval _batch_trig_kernel(::typeof($f), narrow) =
        _BatchAlternatives(_BatchRepair(_BatchKernel(_batch_signed_trig_range, narrow), Double64(0.03125)),
                           _BatchRepair(_BatchKernel($p, $k), Double64(0.5)))
end

# Outside the direct Taylor branch the scalar sine and cosine share the
# same circular reduction, including reflection of negative angles.
@inline _batch_circle_cis_range(x) =
    _batch_abs_bounded(x, nextfloat(_trig_taylor_cutoff), prevfloat(6.28125))

@inline function _batch_circle_cis(x)
    s, c = _batch_circle_pair(x, false)
    return ComplexDF64(_batch_add(c, zero(Double64)), s)
end

_batch_trig_kernel(::typeof(cis), kernel) =
    _BatchAlternatives(_BatchKernel(_batch_signed_trig_range, kernel),
                       _BatchRepair(_BatchKernel(_batch_circle_cis_range, _batch_circle_cis), Double64(0.5)))
