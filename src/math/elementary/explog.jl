function exp(a::DoubleFloat{T}) where {T<:IEEEFloat}
    isnan(a) && return a
    isinf(a) && return(signbit(a) ? zero(DoubleFloat{T}) : a)

    if iszero(HI(a))
    return one(DoubleFloat{T})
    elseif isone(abs(HI(a))) && iszero(LO(a))
    if HI(a) >= zero(T)
        return DoubleFloat{T}(2.718281828459045, 1.4456468917292502e-16)
    else # isone(-HI(a)) && iszero(LO(a))
        return DoubleFloat{T}(0.36787944117144233, -1.2428753672788363e-17)
    end
    elseif HI(a) >= 710.0
      return inf(DoubleFloat{T})
    elseif HI(a) <= -600.0
      # calc_exp forms exp(|a|), a magnitude near Float64's overflow bound here,
      # and returns its inv(); bits lost in that huge intermediate cannot be
      # recovered by the inversion. Float128 avoids the huge intermediate, so
      # the result is as accurate as a Double64 can represent (below a ~ -670
      # the low word is subnormal, which caps the attainable precision).
      # This also extends the domain to the true underflow point near -745.2;
      # below it the conversion rounds to zero.
      return DoubleFloat{T}(exp(Float128(a)))
    end

    z = calc_exp(a)
    # true overflow is at ln(floatmax(T)), ~709.7827 for Float64; calc_exp
    # signals it with a nonfinite hi word
    isfinite(HI(z)) || return inf(DoubleFloat{T})
    return z
end

function exp_taylor(a::DoubleFloat{T}) where {T<:IEEEFloat}
    x = a
    x2 = x*x
    x3 = x*x2
    x4 = x2*x2
    x5 = x2*x3
    x10 = x5*x5
    x15 = x5*x10
    x20 = x10*x10
    x25 = x10*x15

    z = x + inv_fact[2]*x2 + inv_fact[3]*x3 + inv_fact[4]*x4
    z2 = x5 * (inv_fact[5] + x*inv_fact[6] + x2*inv_fact[7] +
         x3*inv_fact[8] + x4*inv_fact[9])
    z3 = x10 * (inv_fact[10] + x*inv_fact[11] + x2*inv_fact[12] +
         x3*inv_fact[13] + x4*inv_fact[14])
    z4 = x15 * (inv_fact[15] + x*inv_fact[16] + x2*inv_fact[17] +
         x3*inv_fact[18] + x4*inv_fact[19])
    z5 = x20 * (inv_fact[20] + x*inv_fact[21] + x2*inv_fact[22] +
         x3*inv_fact[23] + x4*inv_fact[24])
    z6 = x25 * (inv_fact[25] + x*inv_fact[26] + x2*inv_fact[27])

    ((((z6+z5)+z4)+z3)+z2)+z + one(DoubleFloat{T})
end


@inline exp_zero_half(a::DoubleFloat{T}) where {T<:IEEEFloat} = exp_taylor(a)

@inline function exp_half_one(a::DoubleFloat{T}) where {T<:IEEEFloat}
    z = mul_by_half(a)
    z = exp_zero_half(z)
    z = square(z)
    return z
end

function mul_by_half(r::DoubleFloat{T}) where {T<:IEEEFloat}
    return DoubleFloat{T}(ldexp(r.hi, -1), ldexp(r.lo, -1))
end

function mul_by_two(r::DoubleFloat{T}) where {T<:IEEEFloat}
    return DoubleFloat{T}(ldexp(r.hi, 1), ldexp(r.lo, 1))
end

function Base.:(^)(r::DoubleFloat{T}, n::Int) where {T<:IEEEFloat}
    if (n == 0)
        return one(DoubleFloat{T})
    end

    s = one(DoubleFloat{T})
    nabs = abs(n)

    if (nabs > 1)
        while nabs > 0
           if nabs % 2 == 1
              s = s*r
           end
           nabs = div(nabs, 2)
           if nabs > 0
               r = square(r)
           end
        end
    else
        s = r
    end

    if (n < 0)
        s = inv(s)
    end
    return s
end

function Base.:(^)(r::DoubleFloat{T}, n::DoubleFloat{T}) where {T <: IEEEFloat}
    if isinteger(n) && n ≤ min(2^20, maxintfloat(T, Int64))
        return r^Int64(n.hi)
    else
        return exp(n * log(r))
    end
end

# Float64 images of the coefficient tables, for series tails whose terms
# are small enough that Float64 accuracy suffices
const inv_fact_f64 = map(x -> HI(x), inv_fact)
const inv_fact_lo  = map(x -> LO(x), inv_fact)

# one Horner step  (chi,clo) + m*(ph,pl)  on raw hi/lo pairs.
# REQUIRES |chi| >= |m*ph| (guaranteed in a convergent series Horner where
# coefficients dominate), which permits the branch-free two_hilo_sum and
# makes this fully accurate at roughly half the flops of the general path.
@inline function _horner_step(chi::T, clo::T, m::T, ph::T, pl::T) where {T<:IEEEFloat}
    th, tl = two_prod(ph, m)
    tl = fma(pl, m, tl)
    s, e = two_hilo_sum(chi, th)
    return two_hilo_sum(s, (clo + tl) + e)
end

# exp(j/32) for j in 0:31
const exp_frac32 = (
  Double64(1.0,0.0),
  Double64(1.0317434074991028,-8.944417741043132e-17),
  Double64(1.0644944589178593,1.0872888143211957e-16),
  Double64(1.0982851403078258,9.070644949793751e-17),
  Double64(1.1331484530668263,-5.370737708558031e-18),
  Double64(1.1691184461695043,6.945488167320411e-17),
  Double64(1.2062302494209807,3.9295715071105525e-17),
  Double64(1.2445201077660952,-7.440512295261056e-17),
  Double64(1.2840254166877414,8.968972781793724e-17),
  Double64(1.3247847587288655,9.422682377542367e-17),
  Double64(1.3668379411737963,5.1449446596411544e-17),
  Double64(1.4102260349257107,-4.1758810273684196e-17),
  Double64(1.4549914146182013,8.517923078996071e-17),
  Double64(1.5011778000001228,-4.5384955300459954e-17),
  Double64(1.5488302986341331,-3.110014802562223e-17),
  Double64(1.5979954499506333,1.6864630310268093e-17),
  Double64(1.6487212707001282,-4.731568479435833e-17),
  Double64(1.7010573018484008,-8.072967635944199e-17),
  Double64(1.7550546569602985,5.915225890357474e-17),
  Double64(1.8107660721193872,-6.251493697502345e-17),
  Double64(1.8682459574322223,8.036849362605154e-17),
  Double64(1.9275504501675447,-6.540853129828781e-18),
  Double64(1.988737469582292,-8.571894776669697e-17),
  Double64(2.0518667734879767,7.632211812059116e-17),
  Double64(2.117000016612675,-1.1571006249440234e-16),
  Double64(2.184200810815618,2.5424224894086933e-17),
  Double64(2.2535347872132085,-7.513914099665834e-19),
  Double64(2.325069660277121,1.997942766139441e-17),
  Double64(2.398875293967098,-1.7324110869068432e-16),
  Double64(2.475023769963025,1.2616055811901818e-16),
  Double64(2.553589458062927,6.431266858673776e-17),
  Double64(2.6346490888156313,-2.0079668677960811e-16),
)

# exp(r) = 1 + r*P(r) for |r| <= 1/32 + eps, with P(r) = sum(r^(k-1)/k!).
# Terms 9..15 have relative size below 2^-58, so a Float64 Horner tail
# is accurate to < 2^-111; truncation after 1/15! is below 2^-110.
# The Horner recurrence multiplies by the *Float64* hi word only; the lo
# word enters once at the end through the exact identity
# exp(rh + rl) = exp(rh)*exp(rl) = exp(rh)*(1 + rl) + O(rl^2), rl^2 < 2^-116.
@inline function exp_small_frac(r::DoubleFloat{T}) where {T<:IEEEFloat}
    rh = HI(r); rl = LO(r)
    pf = inv_fact_f64[15]
    for k in 14:-1:9
        pf = inv_fact_f64[k] + rh * pf
    end
    ph = inv_fact_f64[8]
    pl = inv_fact_lo[8] + rh * pf
    for k in 7:-1:1
        ph, pl = _horner_step(inv_fact_f64[k], inv_fact_lo[k], rh, ph, pl)
    end
    zh, zl = _horner_step(one(T), zero(T), rh, ph, pl)     # exp(rh)
    s, e = two_hilo_sum(zh, zh * rl)                       # *(1 + rl)
    return DoubleFloat{T}(two_hilo_sum(s, zl + e)...)
end

function calc_exp(a::DoubleFloat{T}) where {T<:IEEEFloat}
    is_neg = signbit(HI(a))
    xabs = is_neg ? -a : a
    xhi = xabs.hi
    xlo = xabs.lo
    xint = trunc(Int64, xhi)
    if xhi == T(xint) && signbit(xlo)
        xint -= 1
    end
    xfrac = xabs - T(xint)

    if 0 < xint <= 64
        zint = exp_int[xint]
    elseif xint === zero(Int64)
        zint = zero(DoubleFloat{T})
    else
        dv, rm = divrem(xint, 64)
        zint = exp_int[64]^dv
        if rm > 0
            zint = zint * exp_int[rm]
        end
    end

    # exp(xfrac), xfrac in [0, 1): split exactly as j/32 + r with
    # |r| < 1/32 + eps (j/32 is exact, so the subtraction is exact too),
    # then exp(xfrac) = exp(j/32) * exp(r) with a short series for exp(r)
    # xfrac.hi can be exactly 1.0 (integer x with a negative lo word);
    # clamp j so r = 1/32 + lo, still within the series bound
    j = min(unsafe_trunc(Int, HI(xfrac) * 32.0), 31)
    r = xfrac - T(0.03125) * j
    zfrac = exp_frac32[j + 1] * exp_small_frac(r)

    z = HI(zint) == zero(T) ? zfrac : zint * zfrac
    if is_neg
        z = inv(z)
    end

    return z
end

#=
this is inaccurate for e.g. x=1.0e-16
the fix is to redesign it completely
for the meanwhile --  we replace it

function expm1(a::DoubleFloat{T}) where {T<:IEEEFloat}
    isnan(a) && return a
    isinf(a) && return(signbit(a) ? zero(DoubleFloat{T}) : a)
    u = exp(a)
    # temp fix of if (u == one(DoubleFloat{T}))
    if (isone(u.hi))
        a
    elseif (u-1.0 == -one(DoubleFloat{T}))
        -one(DoubleFloat{T})
    else
        a*(u-1.0) / log(u)
    end
end
=#

# expm1(x) = x * P(x) for |x| <= 0.25, with P(x) = sum(x^(k-1)/k!).
# The multiplicative form keeps full relative precision as x -> 0.
# Terms 13..22 have relative size below 2^-56 (Float64 tail suffices);
# truncation after 1/22! is below 2^-112.
# Float64-multiplier Horner on the hi word; the lo word enters once at the
# end:  expm1(xh + xl) = expm1(xh) + exp(xh)*xl + O(xl^2), with
# exp(xh) = 1 + expm1(xh) and xl^2 below 2^-109 relative.
function expm1_small(x::DoubleFloat{T}) where {T<:IEEEFloat}
    xh = HI(x); xl = LO(x)
    pf = inv_fact_f64[22]
    for k in 21:-1:13
        pf = inv_fact_f64[k] + xh * pf
    end
    ph = inv_fact_f64[12]
    pl = inv_fact_lo[12] + xh * pf
    for k in 11:-1:1
        ph, pl = _horner_step(inv_fact_f64[k], inv_fact_lo[k], xh, ph, pl)
    end
    uh, ul = two_prod(ph, xh)           # expm1(xh) = xh * P(xh)
    ul = fma(pl, xh, ul)
    uh, ul = two_hilo_sum(uh, ul)
    s, e = two_hilo_sum(uh, fma(uh, xl, xl))   # + (1 + u)*xl
    return DoubleFloat{T}(two_hilo_sum(s, ul + e)...)
end

function expm1(a::DoubleFloat{T}) where {T<:IEEEFloat}
    isnan(a) && return a
    isinf(a) && return signbit(a) ? -one(DoubleFloat{T}) : a
    ax = abs(HI(a))
    if ax <= 0.25
        return expm1_small(a)
    elseif ax <= 1.0
        # half twice, then expm1(2t) = expm1(t) * (expm1(t) + 2) twice;
        # the identity is cancellation-free
        u = expm1_small(DoubleFloat{T}(ldexp(HI(a), -2), ldexp(LO(a), -2)))
        u = u * (u + 2.0)
        return u * (u + 2.0)
    end
    # |a| > 1: exp(a) - 1 amplifies error by at most e/(e-1) < 1.6
    return exp(a) - 1.0
end

# exp(a * log(b)) transforms the *whole* argument, so the product's
# 2^-106 relative error becomes |a|*2^-106 absolute in the exponent and
# the result loses ~|a| ulps.  Split off the integer part first: the
# scaling 2^n (exact) or 10^n (one table multiply) carries the magnitude,
# and only |r| <= 1/2 passes through the transform, keeping its error
# below 2^-107.

function exp2(a::DoubleFloat{T}) where {T<:IEEEFloat}
    isnan(a) && return a
    isinf(a) && return(signbit(a) ? zero(DoubleFloat{T}) : a)
    HI(a) >= 1024.0 && return inf(DoubleFloat{T})
    HI(a) < -1075.0 && return zero(DoubleFloat{T})
    n = round(Int, HI(a))
    r = a - T(n)                                  # exact
    z = exp(r * logtwo(DoubleFloat{T}))
    return ldexp(z, n)
end

# 10^(16k) for k in 0:19
const ten_pow16 = (
  Double64(1.0,0.0),
  Double64(1.0e16,0.0),
  Double64(1.0e32,-5.366162204393472e15),
  Double64(1.0e48,-4.38458430450762e31),
  Double64(1.0e64,-2.1320419009454396e47),
  Double64(1.0e80,-2.6609864708367274e61),
  Double64(1.0e96,-4.9861653971908895e79),
  Double64(1.0e112,6.988006530736956e95),
  Double64(1.0e128,-7.51744869165182e111),
  Double64(1.0e144,-2.3745432358651106e127),
  Double64(1.0e160,-6.528407745068227e142),
  Double64(1.0e176,-7.44898050207432e158),
  Double64(1.0e192,-4.09008802087614e175),
  Double64(1.0e208,1.8136930169189052e191),
  Double64(1.0e224,3.0450964820516807e207),
  Double64(1.0e240,-1.3946113804119925e223),
  Double64(1.0e256,-3.012765990014054e239),
  Double64(1.0e272,-6.552261095746788e255),
  Double64(1.0e288,-7.6304735395750355e270),
  Double64(1.0e304,6.0746447494463536e287),
)

# 10^m for 0 <= m <= 319: 10^j is exact in Float64 for j <= 15, so this
# costs one double-double multiply (~0.75 ulp total)
@inline function _ten_pow(m::Int)
    q, j = divrem(m, 16)
    return ten_pow16[q + 1] * (10.0^j)
end

function exp10(a::DoubleFloat{T}) where {T<:IEEEFloat}
    isnan(a) && return a
    isinf(a) && return(signbit(a) ? zero(DoubleFloat{T}) : a)
    HI(a) >= 308.9 && return inf(DoubleFloat{T})
    HI(a) < -324.9 && return zero(DoubleFloat{T})
    n = round(Int, HI(a))
    r = a - T(n)                                  # exact
    z = exp(r * logten(DoubleFloat{T}))
    p = n >= 0 ? z * _ten_pow(n) : z / _ten_pow(-n)
    return DoubleFloat{T}(p)
end

#=
# ratio of polys from
# https://github.com/sukop/doubledouble/blob/master/doubledouble.py
function calc_exp_frac(x::DoubleFloat{T}) where {T<:AbstractFloat}
  u = (((((((((((x +
                   156.0)*x + 12012.0)*x +
                   600600.0)*x + 21621600.0)*x +
                   588107520.0)*x + 12350257920.0)*x +
                   201132771840.0)*x + 2514159648000.0)*x +
                   23465490048000.0)*x + 154872234316800.0)*x +
                   647647525324800.0)*x + 1295295050649600.0
   v = (((((((((((x -
                   156.0)*x + 12012.0)*x -
                   600600.0)*x + 21621600.0)*x -
                   588107520.0)*x + 12350257920.0)*x -
                   201132771840.0)*x + 2514159648000.0)*x -
                   23465490048000.0)*x + 154872234316800.0)*x -

function exp2(a::DoubleFloat{T}) where {T<:AbstractFloat}
    isnan(x) && return x
    isinf(x) && return(signbit(x) ? zero(DoubleFloat{T}) : x)
    return 2^a
end
647647525324800.0)*x + 1295295050649600.0
  u = u/v
  return u
end
=#

# log(1 + j/16) for j in 0:15
const log_anchor16 = (
  Double64(0.0,0.0),
  Double64(0.06062462181643484,2.6424025938726934e-18),
  Double64(0.11778303565638346,-1.1971685747593677e-18),
  Double64(0.17185025692665923,-6.0224538210113705e-18),
  Double64(0.22314355131420976,-9.091270597324799e-18),
  Double64(0.27193371548364176,7.83319637697442e-19),
  Double64(0.3184537311185346,2.7114779367326236e-17),
  Double64(0.3629054936893685,-2.1492361455310972e-17),
  Double64(0.4054651081081644,-2.8811380259626426e-18),
  Double64(0.44628710262841953,-1.8182541194649598e-17),
  Double64(0.4855078157817008,-1.6618350693852048e-17),
  Double64(0.5232481437645479,-3.1833882216350925e-17),
  Double64(0.5596157879354227,2.685492580212308e-17),
  Double64(0.5947071077466928,1.3751689964323675e-17),
  Double64(0.6286086594223741,4.3538742607970387e-17),
  Double64(0.661398482245365,-7.603333785634003e-18),
)

function log(x::DoubleFloat{T}) where {T<:IEEEFloat}
    isnan(x) && return x
    isinf(x) && !signbit(x) && return x
    x === zero(DoubleFloat{T}) && return neginf(DoubleFloat{T})

    if 0.75 <= HI(x) <= 1.375
        # this close to 1, any decomposition with an m*ln2 or anchor term
        # would cancel against the small result; x - 1 is exact here, and
        # the atanh series in log1p keeps full relative precision however
        # close x is to 1
        return log1p(x - one(DoubleFloat{T}))
    end
    signbit(HI(x)) && return DoubleFloat{T}(log(HI(x)), zero(T))  # throws DomainError

    # reduce exactly: x = 2^m * f with f in [1, 2), then anchor f against
    # a = 1 + j/16, so that log(x) = m*ln2 + log(a) + log1p((f - a)/a)
    # with |(f - a)/a| <= 1/16, deep inside log1p's fast series window.
    # away from the near-1 window, |log x| >= 0.29 while the largest term
    # is |m|*ln2 + 0.7, so the additions lose at most ~1.2*2^-106 relative.
    m = exponent(HI(x))
    f = DoubleFloat{T}(ldexp(HI(x), -m), ldexp(LO(x), -m))
    j = unsafe_trunc(Int, (HI(f) - 1.0) * 16.0)
    a = 1.0 + T(0.0625) * j
    d = (f - a) / a
    y = log1p_small(d) + log_anchor16[j + 1]
    return m == 0 ? y : y + (m * logtwo(DoubleFloat{T}))
end


# 1 / (2i + 1)
const inv_oddint = (
  Double64(0.3333333333333333,1.850371707708594e-17),     # 1/3
  Double64(0.2,-1.1102230246251566e-17),                  # 1/5
  Double64(0.14285714285714285,7.93016446160826e-18),     # 1/7
  Double64(0.1111111111111111,6.1679056923619804e-18),    # 1/9
  Double64(0.09090909090909091,-2.523234146875356e-18),   # 1/11
  Double64(0.07692307692307693,-4.270088556250602e-18),   # 1/13
  Double64(0.06666666666666667,9.251858538542971e-19),    # 1/15
  Double64(0.058823529411764705,8.163404592832033e-19),   # 1/17
  Double64(0.05263157894736842,2.921639538487254e-18),    # 1/19
  Double64(0.047619047619047616,2.64338815386942e-18),    # 1/21
  Double64(0.043478260869565216,1.206764157201257e-18),   # 1/23
  Double64(0.04,-8.326672684688674e-19),                  # 1/25
  Double64(0.037037037037037035,2.05596856412066e-18),    # 1/27
  Double64(0.034482758620689655,4.785444071660157e-19),   # 1/29
  Double64(0.03225806451612903,8.953411488912552e-19),    # 1/31
  Double64(0.030303030303030304,-8.410780489584519e-19),  # 1/33
  Double64(0.02857142857142857,8.921435019309293e-19),    # 1/35
  Double64(0.02702702702702703,-1.50030138462859e-18),    # 1/37
  Double64(0.02564102564102564,8.896017825522087e-19),    # 1/39
  Double64(0.024390243902439025,-8.46206573647223e-19),   # 1/41
)

# log1p(u) for -0.25 <= u <= 0.375, via log(1+u) = 2*atanh(u/(2+u)).
# The series in s = u/(2+u) keeps full relative precision as u -> 0;
# with |s| <= 0.158 the first omitted term (s^42/43) is below 2^-117.
const inv_oddint_f64 = map(x -> HI(x), inv_oddint)
const inv_oddint_lo  = map(x -> LO(x), inv_oddint)

function log1p_small(u::DoubleFloat{T}) where {T<:IEEEFloat}
    s = u / (2.0 + u)
    s2 = square(s)
    # terms 11..20 have relative size below 2^-53 (s2 <= 0.025), so a
    # Float64 Horner tail is accurate to < 2^-108
    s2h = HI(s2); s2l = LO(s2)
    pf = inv_oddint_f64[20]
    for k in 19:-1:11
        pf = inv_oddint_f64[k] + s2h * pf
    end
    # Float64-multiplier Horner on the hi word, W(s2h); the lo word of s2
    # is applied through the first-order correction W'(s2h)*s2l, with W'
    # evaluated in Float64 (it only needs ~2^-49 absolute accuracy)
    ph = inv_oddint_f64[10]
    pl = inv_oddint_lo[10] + s2h * pf
    for k in 9:-1:1
        ph, pl = _horner_step(inv_oddint_f64[k], inv_oddint_lo[k], s2h, ph, pl)
    end
    wp = 9.0 * inv_oddint_f64[10]
    for k in 8:-1:1
        wp = k * inv_oddint_f64[k+1] + s2h * wp
    end
    ph, pl = two_hilo_sum(ph, wp * s2l + pl)
    p = s2 * DoubleFloat{T}(ph, pl)     # full mul: keeps s2's lo here too
    return DoubleFloat{T}(mul_by_two(s + s * p))
end

function log1p(x::DoubleFloat{T})  where {T<:IEEEFloat}
    isnan(x) && return x
    isinf(x) && !signbit(x) && return x
    # this window must cover u = x - 1 for every x that log() routes here,
    # so that log(one + x) below cannot cycle back into log1p
    -0.25 <= HI(x) <= 0.375 && return log1p_small(x)
    return log(one(DoubleFloat{T}) + x)
end

logten(::Type{DoubleFloat{Float64}}) = Double64(2.302585092994046, -2.1707562233822494e-16)
logtwo(::Type{DoubleFloat{Float64}}) = Double64(0.6931471805599453, 2.3190468138462996e-17)
logtwo(::Type{DoubleFloat{Float32}}) = Double32(0.6931472, -1.9046542e-9)
logten(::Type{DoubleFloat{Float32}}) = Double32(2.3025851, -3.1975436e-8)
logtwo(::Type{DoubleFloat{Float16}}) = Double16(0.6934, -0.0002122)
logten(::Type{DoubleFloat{Float16}}) = Double16(2.303, -0.0001493)

const invlogtwo64 = inv(logtwo(DoubleFloat{Float64}))
const invlogten64 = inv(logten(DoubleFloat{Float64}))
const invlogtwo32 = inv(logtwo(DoubleFloat{Float32}))
const invlogten32 = inv(logten(DoubleFloat{Float32}))
const invlogtwo16 = inv(logtwo(DoubleFloat{Float16}))
const invlogten16 = inv(logten(DoubleFloat{Float16}))

invlogtwo(::Type{DoubleFloat{Float64}}) = invlogtwo64
invlogten(::Type{DoubleFloat{Float64}}) = invlogten64
invlogtwo(::Type{DoubleFloat{Float32}}) = invlogtwo32
invlogten(::Type{DoubleFloat{Float32}}) = invlogten32
invlogtwo(::Type{DoubleFloat{Float16}}) = invlogtwo16
invlogten(::Type{DoubleFloat{Float16}}) = invlogten16

function log2(x::DoubleFloat{T}) where {T<:IEEEFloat}
    isnan(x) && return x
    isinf(x) && !signbit(x) && return x
    log(x) * invlogtwo(DoubleFloat{T})
end

function log10(x::DoubleFloat{T}) where {T<:IEEEFloat}
    isnan(x) && return x
    isinf(x) && !signbit(x) && return x
    log(x) * invlogten(DoubleFloat{T})
end
