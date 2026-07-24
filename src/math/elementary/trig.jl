const twopi  = Double64(6.283185307179586, 2.4492935982947064e-16)
const onepi  = Double64(3.141592653589793, 1.2246467991473532e-16)
const halfpi = Double64(1.5707963267948966, 6.123233995736766e-17)
const qrtrpi = Double64(0.7853981633974483, 3.061616997868383e-17)
const sixteenthpi = Double64(0.19634954084936207, 7.654042494670958e-18)
const thirtysecondpi = Double64(0.09817477042468103, 3.827021247335479e-18)
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
@inline function _sincos_taylor_core(ah::Float64, al::Float64)
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
    Sh, Sl = two_hilo_sum(Sh, Sp * yl + Sl)
    Ch, Cl = two_hilo_sum(Ch, Cp * yl + Cl)
    sh, sl = two_prod(Sh, ah)                        # sin(ah) = ah*S
    sl = fma(Sl, ah, sl)
    sh, sl = two_hilo_sum(sh, sl)
    # cross corrections for a's lo word use the already-computed hi words,
    # which carry cos(ah) and sin(ah) to well past Float64 accuracy
    s1, e1 = two_hilo_sum(sh, Ch * al)
    c1, e2 = two_hilo_sum(Ch, -sh * al)
    return DoubleFloat{Float64}(two_hilo_sum(s1, sl + e1)...),
           DoubleFloat{Float64}(two_hilo_sum(c1, Cl + e2)...)
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

# sin and cos of w for |w| <= π/4 + eps
@inline function sincos_quadrant(w::DoubleFloat{T}) where {T<:IEEEFloat}
    if abs(HI(w)) <= 0.09817477042468103         # π/32: direct Taylor pair
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
    q = unsafe_trunc(Int, HI(x) * 0.6366197723675814 + 0.5)   # round(x/(π/2))
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
        HI(ax) <= 0.09817477042468103 && return cos_taylor(ax)
        return sincos_kernel(ax)[2]
    end
    return abs(x.hi) < 6.28125 ? cos_kernel(x) : DoubleFloat{T}(cos(Quadmath.Float128(x)))
end

function sin(x::DoubleFloat{T}) where {T<:IEEEFloat}
    isnan(x) && return x
    isinf(x) && throw(DomainError("sin(x) only defined for finite x"))
    if T === Float64 && abs(x.hi) < 6.28125
        HI(abs(x)) <= 0.09817477042468103 && return sin_taylor(x)
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
