# ---------------------------------------------------------------------------
# MultiFloats v3.0 double-word kernels (mfadd/mfmul/mfsqr/mfdiv, N = 2),
# operating on (hi, lo) tuples.  two_sum_ / two_hilo_sum_ / two_prod_ are the
# branch-free error-free transformations from math/errorfree.jl.
#
# Every caller of these kernels lives in this file, and each one either keeps
# its operands well inside the exponent range (series arguments |r| <= 1/16,
# reduced mantissas in [1, 2), table centers, exponents as floats) or routes
# non-finite input around the kernel with a post-hoc select — _exp2_clamped
# for the exp family, _log_special for the log family.  Nothing here can
# newly overflow, so the saturating `!isfinite` guard inside the public EFTs
# is dead weight.  Dropping it (together with the fused Horner step below)
# takes exp2(::Double64) from 384 branches and 2979 lines of LLVM IR to 3
# and 205, and leaves the remaining straight-line code vectorizable.
# ---------------------------------------------------------------------------

@inline function _mf_add(x::Tuple{T,T}, y::Tuple{T,T}) where {T<:IEEEFloat}
    a, b = two_sum_(x[1], y[1])
    c, d = two_sum_(x[2], y[2])
    a, c = two_hilo_sum_(a, c)
    b = (b + d) + c
    return two_hilo_sum_(a, b)
end

@inline function _mf_mul(x::Tuple{T,T}, y::Tuple{T,T}) where {T<:IEEEFloat}
    p, e = two_prod_(x[1], y[1])
    e = e + fma(x[1], y[2], x[2] * y[1])
    return two_hilo_sum_(p, e)
end

@inline function _mf_sqr(x::Tuple{T,T}) where {T<:IEEEFloat}
    p, e = two_prod_(x[1], x[1])
    e = fma(x[1], x[2] + x[2], e)
    return two_hilo_sum_(p, e)
end

# reciprocal-based (Karp–Markstein): differs from dvi_dddd_dd, which divides.
@inline function _mf_div(x::Tuple{T,T}, y::Tuple{T,T}) where {T<:IEEEFloat}
    w = inv(y[1])
    z = x[1] * w
    # residual x - y*z.  fma(-y[1], z, x[1]) is the correctly rounded leading
    # residual, replacing a two_prod plus two subtractions; the second fma
    # folds in the y[2] correction alongside x[2].
    r = fma(-y[1], z, x[1]) + fma(-y[2], z, x[2])
    return two_hilo_sum_(z, r * w)
end

# ---------------------------------------------------------------------------
# Exact exponent-field helpers (MultiFloats unsafe_exponent / unsafe_ldexp).
# Valid for normal, finite values only — which the callers guarantee.
# ---------------------------------------------------------------------------

@inline _int_type(::Type{Float64}) = Int64
@inline _int_type(::Type{Float32}) = Int32

@inline function _pow2(::Type{T}, k::Integer) where {T<:IEEEFloat}
    U = Base.uinttype(T)
    return reinterpret(T,
        reinterpret(U, one(T)) + (k % U) << Base.significand_bits(T))
end

@inline function _raw_exponent(x::T) where {T<:IEEEFloat}
    U = Base.uinttype(T)
    biased = (reinterpret(U, x) & Base.exponent_mask(T)) >>
             Base.significand_bits(T)
    return Int(biased) - Base.exponent_bias(T)
end

@inline function _uldexp(x::T, k::Integer) where {T<:IEEEFloat}
    U = Base.uinttype(T)
    shifted = reinterpret(U, x) + (k % U) << Base.significand_bits(T)
    return ifelse(iszero(x), x, reinterpret(T, shifted))
end

@inline function _log2_index(x::T) where {T<:IEEEFloat}
    U = Base.uinttype(T)
    return Int((reinterpret(U, x) >> (Base.significand_bits(T) - 5)) & U(0x1F))
end

# ---------------------------------------------------------------------------
# Shared helpers used outside this file (trig.jl, arctrig.jl, archyptrig.jl,
# hyptrig.jl, linearalgebra/matfun.jl).  These predate the kernel rewrite and
# must remain here: the files that consume them are included after explog.jl.
# ---------------------------------------------------------------------------

# multiplication by an exact power of two is correctly rounded, so these
# match ldexp bit-for-bit (including subnormals) without its branches
@inline function mul_by_half(r::DoubleFloat{T}) where {T<:IEEEFloat}
    return DoubleFloat{T}(r.hi * T(0.5), r.lo * T(0.5))
end

@inline function mul_by_two(r::DoubleFloat{T}) where {T<:IEEEFloat}
    return DoubleFloat{T}(r.hi * T(2.0), r.lo * T(2.0))
end

# one Horner step  (chi,clo) + m*(ph,pl)  on raw hi/lo pairs.
# REQUIRES |chi| >= |m*ph| (guaranteed in a convergent series Horner where
# coefficients dominate), which permits the branch-free two_hilo_sum and
# makes this fully accurate at roughly half the flops of the general path.
#
# The branch-free EFTs are what that precondition buys.  Every caller —
# _sincos_taylor_core in trig.jl, _atan_small in arctrig.jl — is reached
# only after its entry point has rejected non-finite input, and evaluates a
# convergent series in a reduced argument, so no operand here can overflow.
@inline function _horner_step(chi::T, clo::T, m::T, ph::T, pl::T) where {T<:IEEEFloat}
    th, tl = two_prod_(ph, m)
    tl = fma(pl, m, tl)
    s, e = two_hilo_sum_(chi, th)
    return two_hilo_sum_(s, (clo + tl) + e)
end

# the same fusion for a double-word multiplier: one Horner step  c + p*r  on
# raw (hi, lo) pairs.  A separate _mf_mul then _mf_add renormalizes twice and
# throws away the exact product bits in between; keeping them costs a third
# of the flops and a much shorter dependency chain.
#
# REQUIRES |c[1]| >= |hi(p*r)|, as _horner_step does.  In the series below
# the coefficient ratio |c_{k+1}/c_k| stays under 3/4 and the argument is
# bounded by 1/16, so the incoming term is at most |c[1]|/16.
@inline function _horner_step_dd(c::Tuple{T,T}, p::Tuple{T,T},
                                 r::Tuple{T,T}) where {T<:IEEEFloat}
    th, tl = two_prod_(p[1], r[1])
    # both cross terms in one independent fma, off the critical path: tl
    # arrives late from two_prod_, and this way it waits on a single add
    # rather than on a chain of two fmas.  The extra rounding lands on a
    # second-order term, ~2^-2p below the step's leading bits.
    tl = tl + fma(p[1], r[2], p[2] * r[1])
    s, e = two_hilo_sum_(c[1], th)
    return two_hilo_sum_(s, (c[2] + tl) + e)
end

# entry step: the accumulator is still a bare scalar (the tapered tail), so
# the p[2]*r[1] correction is identically zero
@inline function _horner_step_dd(c::Tuple{T,T}, p::T,
                                 r::Tuple{T,T}) where {T<:IEEEFloat}
    th, tl = two_prod_(p, r[1])
    tl = fma(p, r[2], tl)
    s, e = two_hilo_sum_(c[1], th)
    return two_hilo_sum_(s, (c[2] + tl) + e)
end

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

const inv_oddint_f64 = map(x -> HI(x), inv_oddint)
const inv_oddint_lo  = map(x -> LO(x), inv_oddint)

## 3. The `exp2` / `exp` / `exp10` family

### Constants

# clamp bounds on the leading limb of the base-2 argument (exp.jl:1)
@inline _exp2_min(::Type{Float64}) = -0x1.FF00000000000p+0009   # -1022.0
@inline _exp2_max(::Type{Float64}) = +0x1.FFFFFFFFFFFFFp+0009   # ~1024.0
@inline _exp2_min(::Type{Float32}) = Float32(-0x1.F80000p+006)  # -126.0f0
@inline _exp2_max(::Type{Float32}) = Float32(+0x1.FFFFFEp+006)  # ~128.0f0

# below this, 2^x rounds to zero even in the subnormals (safely past
# -1075.0 / -150.0f0, the exact round-to-zero cutoffs)
@inline _exp2_zero(::Type{Float64}) = -1080.0
@inline _exp2_zero(::Type{Float32}) = -155.0f0

# 2-limb base-conversion constants (heads of the MultiFloats full tables)
@inline _log2_e(::Type{Float64}) =
    (+0x1.71547652B82FEp+0000, +0x1.777D0FFDA0D24p-0056)
@inline _log2_10(::Type{Float64}) =
    (+0x1.A934F0979A371p+0001, +0x1.7F2495FB7FA6Dp-0053)
@inline _log2_e(::Type{Float32}) =
    (Float32(+0x1.715476p+000), Float32(+0x1.4AE0C0p-026))
@inline _log2_10(::Type{Float32}) =
    (Float32(+0x1.A934F0p+001), Float32(+0x1.2F346Ep-024))

# 3-limb versions: a 2-limb constant times a 2-limb x truncates the base-2
# argument y = x*log2(base) at ~|y|*2^-106, and 2^y amplifies that into
# ln2*|y|*2^-106 of relative error — ~25 ulps at |x| = 100.  Carrying a
# third limb through the conversion removes the growth with |x|.
@inline _log2_e3(::Type{Float64}) =
    (+0x1.71547652B82FEp+0000, +0x1.777D0FFDA0D24p-0056, -0x1.60BB8A5442AB9p-0110)
@inline _log2_10_3(::Type{Float64}) =
    (+0x1.A934F0979A371p+0001, +0x1.7F2495FB7FA6Dp-0053, +0x1.FB699B2D8ABFCp-0107)
@inline _log2_e3(::Type{Float32}) =
    (Float32(+0x1.715476p+000), Float32(+0x1.4AE0C0p-026), Float32(-0x1.E8883p-052))
@inline _log2_10_3(::Type{Float32}) =
    (Float32(+0x1.A934F0p+001), Float32(+0x1.2F346Ep-024), Float32(+0x1.5FC926p-051))

# x (2 limbs) times constant c (3 limbs), to 3 limbs (y1, y2, y3) with
# |y2| <= ulp(y1) and |y3| ~ |y|*2^-105: keeps the product bits a plain
# double-word multiply would discard.
#
# The three products keep the guarded two_prod: they are the only place a
# raw (possibly huge or infinite) x reaches a multiply, and the saturating
# (Inf, 0) convention is what lets exp(+Inf) reconstruct to +Inf downstream.
# Every sum below is fed by those already-saturated values and by quantities
# bounded by ulp(p1), so none can newly overflow — the branch-free EFTs
# apply, leaving the three products as the only branches here.
@inline function _mf_mul3(x::Tuple{T,T}, c::Tuple{T,T,T}) where {T<:IEEEFloat}
    p1, e1 = two_prod(x[1], c[1])
    p2, e2 = two_prod(x[1], c[2])
    p3, e3 = two_prod(x[2], c[1])
    # third-order tail: both product errors plus the two terms a double-word
    # multiply drops outright
    t = fma(x[1], c[3], fma(x[2], c[2], e2 + e3))
    s, u = two_sum_(p2, p3)
    m, v = two_sum_(e1, s)
    # every second-order term is a full limb below p1 (|c2| <= ulp(c1) and
    # |x2| <= ulp(x1)), so |m| <= 2^-51*|p1| and the ordered sum applies
    y1, w = two_hilo_sum_(p1, m)
    return y1, w, (u + v) + t
end

### Polynomial kernels

#=
Tapered minimax approximations of `2^r` on `|r| ≤ 1/16`; coefficients
≈ `(ln 2)^k / k!`. `Float64`: degree 13, 9 double-word + 5 scalar terms
(`exp.jl:68`). `Float32`: degree 7, 5 + 3 (`exp.jl:15`).
=#

@inline function _exp2_poly(r::Tuple{Float64,Float64})
    r1 = r[1]
    t = +0x1.816519F74C4AFp-0040                       # c14
    t = muladd(t, r1, +0x1.C3C1919538484p-0036)        # c13
    t = muladd(t, r1, +0x1.E8CAC72F6E9E5p-0032)        # c12
    t = muladd(t, r1, +0x1.E4CF5152FBB30p-0028)        # c11
    t = muladd(t, r1, +0x1.B5253D395E80Fp-0024)        # c10
    p = _horner_step_dd((+0x1.62C0223A5C863p-0020, -0x1.99EF542AA8E1Ep-0074), t, r)  # c9
    p = _horner_step_dd((+0x1.FFCBFC588B0C7p-0017, -0x1.E645E286FE571p-0071), p, r)  # c8
    p = _horner_step_dd((+0x1.430912F86C787p-0013, +0x1.BC7CDBCDC0339p-0067), p, r)  # c7
    p = _horner_step_dd((+0x1.5D87FE78A6731p-0010, +0x1.0717F88815ADFp-0066), p, r)  # c6
    p = _horner_step_dd((+0x1.3B2AB6FBA4E77p-0007, +0x1.4E65DFEF67D34p-0062), p, r)  # c5
    p = _horner_step_dd((+0x1.C6B08D704A0C0p-0005, -0x1.D3316275139AEp-0059), p, r)  # c4
    p = _horner_step_dd((+0x1.EBFBDFF82C58Fp-0003, -0x1.5E43A53E454F1p-0057), p, r)  # c3
    p = _horner_step_dd((+0x1.62E42FEFA39EFp-0001, +0x1.ABC9E3B39803Fp-0056), p, r)  # c2
    p = _horner_step_dd((+0x1.0000000000000p+0000, +0x1.314BACF0323FFp-0113), p, r)  # c1
    return p
end

@inline function _exp2_poly(r::Tuple{Float32,Float32})
    r1 = r[1]
    t = Float32(+0x1.FFD486p-017)                      # d8
    t = muladd(t, r1, Float32(+0x1.430E9Ep-013))       # d7
    t = muladd(t, r1, Float32(+0x1.5D87FEp-010))       # d6
    p = _horner_step_dd((Float32(+0x1.3B2AB6p-007), Float32(+0x1.DB9286p-032)), t, r)  # d5
    p = _horner_step_dd((Float32(+0x1.C6B08Ep-005), Float32(-0x1.1F6B9Cp-030)), p, r)  # d4
    p = _horner_step_dd((Float32(+0x1.EBFBE0p-003), Float32(-0x1.F4DEB0p-033)), p, r)  # d3
    p = _horner_step_dd((Float32(+0x1.62E430p-001), Float32(-0x1.05C610p-029)), p, r)  # d2
    p = _horner_step_dd((Float32(+0x1.000000p+000), Float32(-0x1.62C458p-059)), p, r)  # d1
    return p
end

### Kernel and public methods

@inline function _exp2_kernel(x::Tuple{T,T}, x3::T = zero(T)) where {T<:IEEEFloat}
    _half   = T(0.5)
    _eighth = T(0.125)
    # reduction: x = n + 8r, n integer, |r| ≤ 1/16              (exact)
    # trunc-based nearest-integer: reproducible across CPU/GPU backends
    n_float = trunc(x[1] + copysign(_half, x[1]))
    # x₁ and n_float share x₁'s ulp grid and differ by ≤ 1/2, so the
    # subtraction is exact; one two_sum replaces the full _mf_add.  Both
    # operands are bounded by 1/2 here, so the branch-free form applies.
    rh, rl = two_sum_(x[1] - n_float, x[2])
    rl += x3          # third limb of the base-conversion product, if any
    r = (_eighth * rh, _eighth * rl)
    # kernel: 2^(x-n) = (2^r)^8
    p = _exp2_poly(r)
    p = _mf_sqr(_mf_sqr(_mf_sqr(p)))
    # reconstruction: · 2^n in two exact halves (avoids over/underflow)
    n = unsafe_trunc(_int_type(T), n_float)
    h = n >> 1
    s1 = _pow2(T, h)
    s2 = _pow2(T, n - h)
    p = (s1 * p[1], s1 * p[2])
    p = (s2 * p[1], s2 * p[2])
    return p
end

@inline function _exp2_clamped(x::Tuple{T,T}, x3::T = zero(T)) where {T<:IEEEFloat}
    p = _exp2_kernel(x, x3)
    # gradual underflow needs no shifted re-run of the kernel: down to
    # _exp2_zero the split exponents h and n-h stay well above the normal
    # limit, so p·s1 is an exact normal scaling and the final ·s2 is the
    # one multiply that rounds correctly into the subnormals (Base.ldexp
    # truncates there).  The low limb is meaningless at subnormal
    # magnitudes and is dropped.  Below _exp2_zero and above _exp2_max the
    # kernel output is garbage (n overflows its exponent field or the
    # integer type) — the selects override it, keeping this branch-free.
    p = ifelse(x[1] < _exp2_min(T), (p[1], zero(T)), p)
    p = ifelse(x[1] < _exp2_zero(T), (zero(T), zero(T)), p)
    return ifelse(x[1] > _exp2_max(T), (T(Inf), T(Inf)), p)
end

const _DF64or32 = Union{Float64, Float32}

# x == 0 short-circuits: the polynomial's constant term carries minimax
# low-limb dust (~2^-113), so the kernel would return 1 + 9e-34 instead of
# the exact 1 that exp(±0.0) must produce.

function Base.exp2(x::DoubleFloat{T}) where {T<:_DF64or32}
    iszero(x) && return one(DoubleFloat{T})
    p = _exp2_clamped(HILO(x))
    return DoubleFloat{T}(p[1], p[2])
end

function Base.exp(x::DoubleFloat{T}) where {T<:_DF64or32}
    iszero(x) && return one(DoubleFloat{T})
    y1, y2, y3 = _mf_mul3(HILO(x), _log2_e3(T))
    p = _exp2_clamped((y1, y2), y3)
    return DoubleFloat{T}(p[1], p[2])
end

function Base.exp10(x::DoubleFloat{T}) where {T<:_DF64or32}
    iszero(x) && return one(DoubleFloat{T})
    y1, y2, y3 = _mf_mul3(HILO(x), _log2_10_3(T))
    p = _exp2_clamped((y1, y2), y3)
    return DoubleFloat{T}(p[1], p[2])
end

# templated.jl promotes exp/expm1/log/log1p/log2/log10 for Double16, but
# exp2/exp10 are not in its list — cover them here the same way
Base.exp2(x::Double16)  = Double16(exp2(Double64(x)))
Base.exp10(x::Double16) = Double16(exp10(Double64(x)))

#=
Behavioral notes:

- NaN propagates through `n_float` and the polynomial naturally; `-Inf`
  hits the low clamp → `0.0`; `+Inf` hits the high clamp →
  `inf(DoubleFloat{T})`. No explicit guards needed.
- Subnormal outputs (`exp2` arguments in `[-1074, -1022)` for `Double64`,
  `[-149, -126)` for `Double32`) are produced by a shifted kernel plus a
  correctly-rounded `ldexp`; the low limb is zero there, matching what a
  subnormal-`hi` double-double can represent.
- `exp2` is exact-reduction throughout and is the most accurate of the
  three; `exp`/`exp10` add one inexact constant multiplication up front.
=#

## 4. The `log2` / `log` / `log10` family

### Constants

@inline _ln_2(::Type{Float64}) =
    (+0x1.62E42FEFA39EFp-0001, +0x1.ABC9E3B39803Fp-0056)
@inline _log10_2(::Type{Float64}) =
    (+0x1.34413509F79FFp-0002, -0x1.9DC1DA994FD21p-0059)
@inline _ln_2(::Type{Float32}) =
    (Float32(+0x1.62E430p-001), Float32(-0x1.05C610p-029))
@inline _log10_2(::Type{Float32}) =
    (Float32(+0x1.344136p-002), Float32(-0x1.EC10C0p-027))

# DoubleFloat-valued ln(2) / ln(10) and reciprocals, used by archyptrig.jl
# (large-argument branches) and linearalgebra/matfun.jl (matrix log2/log10);
# these were dropped in the kernel rewrite while their callers remained
logtwo(::Type{DoubleFloat{Float64}}) = Double64(0.6931471805599453, 2.3190468138462996e-17)
logten(::Type{DoubleFloat{Float64}}) = Double64(2.302585092994046, -2.1707562233822494e-16)
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

# 32-entry lookup table: centers 1 + (2i-1)/64 (exact in T) and log2(center)
# as (hi, lo) pairs, generated at load time (log.jl:185)
for (T, prec) in ((Float64, 160), (Float32, 80))
    centers = ntuple(h -> T(1 + (2h - 1) // 64), 32)
    values = ntuple(32) do i
        b = setprecision(prec) do
            log2(BigFloat(centers[i]))
        end
        hi = T(b)
        (hi, T(b - hi))
    end
    @eval @inline _log2_centers(::Type{$T}) = $centers
    @eval @inline _log2_values(::Type{$T})  = $values
end

### Polynomial kernels

#=
Both are odd-series kernels `log₂((1+t)/(1-t)) = t·P(t²)` with
coefficients ≈ `(2/ln 2)/(2k+1)`, minimax-adjusted, evaluated in
`u = t²`. *Narrow* serves the table path (`|t| ≤ 1/128`); *wide* serves
the direct path near 1 (`|t| ≤ 1/31`). `Float64`: 7 / 9 coefficients
(`log.jl:38`, `log.jl:129`); `Float32`: 4 / 5 (`log.jl:6`, `log.jl:91`).
=#

@inline function _log2_poly_narrow(u::Tuple{Float64,Float64})
    u1 = u[1]
    t = +0x1.C6A48D52BA6C7p-0003                       # k7
    t = muladd(t, u1, +0x1.0C9A845FCF968p-0002)        # k6
    t = muladd(t, u1, +0x1.484B13D7C0C4Dp-0002)        # k5
    p = _horner_step_dd((+0x1.A61762A7ADED9p-0002, +0x1.90D60ECEBE07Fp-0057), t, u)  # k4
    p = _horner_step_dd((+0x1.2776C50EF9BFEp-0001, +0x1.E4B2AE3DCBD87p-0055), p, u)  # k3
    p = _horner_step_dd((+0x1.EC709DC3A03FDp-0001, +0x1.D27F055486A5Ap-0055), p, u)  # k2
    p = _horner_step_dd((+0x1.71547652B82FEp+0001, +0x1.777D0FFDA0D24p-0055), p, u)  # k1
    return p
end

@inline function _log2_poly_wide(u::Tuple{Float64,Float64})
    u1 = u[1]
    t = +0x1.5D108CD7E21EBp-0003                       # w9
    t = muladd(t, u1, +0x1.89F2F69137330p-0003)        # w8
    t = muladd(t, u1, +0x1.C68F56BF8A8ACp-0003)        # w7
    p = _horner_step_dd((+0x1.0C9A84993C2EEp-0002, +0x1.0E0FE2C5542A6p-0056), t, u)  # w6
    p = _horner_step_dd((+0x1.484B13D7C02AFp-0002, -0x1.9282874496178p-0057), p, u)  # w5
    p = _horner_step_dd((+0x1.A61762A7ADED9p-0002, +0x1.F8B804528988Ap-0057), p, u)  # w4
    p = _horner_step_dd((+0x1.2776C50EF9BFEp-0001, +0x1.E4B2A0D0290E2p-0055), p, u)  # w3
    p = _horner_step_dd((+0x1.EC709DC3A03FDp-0001, +0x1.D27F055480ABFp-0055), p, u)  # w2
    p = _horner_step_dd((+0x1.71547652B82FEp+0001, +0x1.777D0FFDA0D24p-0055), p, u)  # w1
    return p
end

@inline function _log2_poly_narrow(u::Tuple{Float32,Float32})
    t = Float32(+0x1.A6217Cp-002)                      # k4
    t = muladd(t, u[1], Float32(+0x1.2776C6p-001))     # k3
    p = _horner_step_dd((Float32(+0x1.EC709Ep-001), Float32(-0x1.E2FDB2p-028)), t, u)  # k2
    p = _horner_step_dd((Float32(+0x1.715476p+001), Float32(+0x1.4AE0C0p-025)), p, u)  # k1
    return p
end

@inline function _log2_poly_wide(u::Tuple{Float32,Float32})
    t = Float32(+0x1.48FE3Ap-002)                      # w5
    t = muladd(t, u[1], Float32(+0x1.A61738p-002))     # w4
    p = _horner_step_dd((Float32(+0x1.2776C6p-001), Float32(-0x1.DE12AAp-026)), t, u)  # w3
    p = _horner_step_dd((Float32(+0x1.EC709Ep-001), Float32(-0x1.E2FE88p-028)), p, u)  # w2
    p = _horner_step_dd((Float32(+0x1.715476p+001), Float32(+0x1.4AE0C0p-025)), p, u)  # w1
    return p
end

### Kernel and public methods

# positive x below this can have a subnormal limb, which breaks the raw
# exponent-field arithmetic; such x are rescaled up exactly first.
#
# The bound is floatmin * 2^(2*precision): a subnormal low limb still holds
# bits the double-word format carries as long as |lo| >= |hi|*2^-2p, i.e. as
# long as |hi| < floatmin*2^2p — 2^-916 for Float64, 2^-78 for Float32.  One
# bit of margin is added.  (The former values, 2^-1000 and 2^-100, covered
# only a subnormal *leading* limb, so a low limb that went subnormal first
# reached _uldexp intact and its exponent field wrapped.)
@inline _log_tiny(::Type{Float64}) = 0x1p-915
@inline _log_tiny(::Type{Float32}) = Float32(0x1p-77)

@inline function _unsafe_log2(x::Tuple{T,T}) where {T<:IEEEFloat}
    _one = one(T)
    _zero = zero(T)
    # rescue non-normal leading limbs.  hi == 0 with lo != 0 (cancellation
    # can leave the value entirely in lo): promote lo to the leading term.
    x = ifelse(iszero(x[1]) & !iszero(x[2]), (x[2], _zero), x)
    # near 1 take the direct path and skip the exponent split, table load,
    # and tabled kernel entirely; numerator is Sterbenz-exact
    if (T(0.9375) < x[1]) & (x[1] < T(1.0625))  # 15/16 < x₁ < 17/16
        t = _mf_div(_mf_add(x, (-_one, _zero)), _mf_add(x, (_one, _zero)))
        return _mf_mul(t, _log2_poly_wide(_mf_sqr(t)))
    end
    # subnormal-limb region: multiply by an exact power of 2, subtract it
    # from the exponent afterwards
    _shift = Base.significand_bits(T) + 2
    tiny = abs(x[1]) < _log_tiny(T)
    _scale = _pow2(T, _shift)
    x = ifelse(tiny, (_scale * x[1], _scale * x[2]), x)
    # the rescale above normalizes any nonzero low limb (the smallest
    # subnormal clears floatmin after 2^_shift), but a low limb can be
    # subnormal for *any* leading limb — Double64(2.0^100, 1e-320) is a legal
    # double-word.  Beyond the _log_tiny band such a limb lies below the
    # 2^-2p the format carries, so dropping it is exact to within the
    # representable precision, whereas feeding it to _uldexp would wrap the
    # exponent field and fabricate a large mantissa correction.
    x = ifelse(abs(x[2]) < floatmin(T), (x[1], _zero), x)
    # exact split: x = 2^er · m,  m₁ ∈ [1, 2)
    er = _raw_exponent(x[1])
    e = er - ifelse(tiny, _shift, 0)
    m = (_uldexp(x[1], -er), _uldexp(x[2], -er))
    i = _log2_index(x[1]) + 1
    c = @inbounds _log2_centers(T)[i]
    v = @inbounds _log2_values(T)[i]
    # numerator is Sterbenz-exact
    t = _mf_div(_mf_add(m, (-c, -_zero)), _mf_add(m, (c, _zero)))
    return _mf_add(_mf_add((T(e), _zero), v),
                   _mf_mul(t, _log2_poly_narrow(_mf_sqr(t))))
end

@inline function _log_special(x::Tuple{T,T}, y::Tuple{T,T}) where {T<:IEEEFloat}
    y = ifelse(iszero(x[1]) & iszero(x[2]), (T(-Inf), T(-Inf)), y)
    y = ifelse(isinf(x[1]) & !signbit(x[1]), (T(Inf), T(Inf)), y)
    y = ifelse(isnan(x[1]), (T(NaN), T(NaN)), y)
    return y
end

# negative arguments throw, matching Base and the pre-rewrite behavior
@inline function _log_domain_check(x::Tuple{T,T}) where {T<:IEEEFloat}
    if (x[1] < zero(T)) | (iszero(x[1]) & (x[2] < zero(T)))
        throw(DomainError(x[1],
            "log requires a non-negative argument; try log(Complex(x))"))
    end
    return nothing
end

function Base.log2(x::DoubleFloat{T}) where {T<:_DF64or32}
    t = HILO(x)
    _log_domain_check(t)
    y = _log_special(t, _unsafe_log2(t))
    return DoubleFloat{T}(y[1], y[2])
end

function Base.log(x::DoubleFloat{T}) where {T<:_DF64or32}
    t = HILO(x)
    _log_domain_check(t)
    y = _log_special(t, _mf_mul(_unsafe_log2(t), _ln_2(T)))
    return DoubleFloat{T}(y[1], y[2])
end

function Base.log10(x::DoubleFloat{T}) where {T<:_DF64or32}
    t = HILO(x)
    _log_domain_check(t)
    y = _log_special(t, _mf_mul(_unsafe_log2(t), _log10_2(T)))
    return DoubleFloat{T}(y[1], y[2])
end

function Base.log1p(x::DoubleFloat{T}) where {T<:_DF64or32}
    u = HI(x)
    (isnan(u) | iszero(u)) && return x
    if -T(0.0625) < u < T(0.0625)
        # inside the wide-poly window use t = x/(2 + x) directly: the
        # double-word division keeps every low bit of x, so nothing is
        # lost forming 1 + x
        t = _mf_div(HILO(x), _mf_add(HILO(x), (T(2), zero(T))))
        y = _mf_mul(_mf_mul(t, _log2_poly_wide(_mf_sqr(t))), _ln_2(T))
        return DoubleFloat{T}(y[1], y[2])
    end
    # elsewhere 1 + x carries full double-word relative accuracy;
    # +Inf passes through, x == -1 gives -Inf, x < -1 throws DomainError
    return log(x + one(x))
end

# expm1 series coefficients 1/j! as per-type (hi, lo) pairs
for (T, prec, nterms) in ((Float64, 160, 12), (Float32, 80, 8))
    coeffs = ntuple(nterms) do j
        b = setprecision(prec) do
            inv(factorial(BigInt(j)))
        end
        hi = T(b)
        (hi, T(b - hi))
    end
    @eval @inline _expm1_coeffs(::Type{$T}) = $coeffs
end

## 5. Powers

function Base.:(^)(r::DoubleFloat{T}, n::Int) where {T<:IEEEFloat}
    n == 0 && return one(DoubleFloat{T})
    s = one(DoubleFloat{T})
    nabs = abs(n)
    if nabs > 1
        while nabs > 0
            if isodd(nabs)
                s = s * r
            end
            nabs >>= 1
            if nabs > 0
                r = square(r)
            end
        end
    else
        s = r
    end
    return n < 0 ? inv(s) : s
end

function Base.:(^)(r::DoubleFloat{T}, n::DoubleFloat{T}) where {T<:IEEEFloat}
    if isinteger(n) && abs(HI(n)) <= 0x1p20
        return r ^ unsafe_trunc(Int, HI(n))
    end
    return exp(n * log(r))
end

function Base.expm1(x::DoubleFloat{T}) where {T<:_DF64or32}
    u = HI(x)
    (isnan(u) | iszero(u)) && return x
    # away from zero exp(x) - 1 does not cancel harmfully (exp(x) ∉ (0.6, 1.65))
    abs(u) >= T(0.5) && return exp(x) - one(x)
    # scale exactly to |s| < 2^-8, run the Taylor series there, then undo the
    # scaling with expm1(2t) = expm1(t)·(expm1(t) + 2); at most 8 doublings
    k = max(0, Base.exponent(u) + 9)
    tw = _pow2(T, -k)
    s = (u * tw, LO(x) * tw)
    c = _expm1_coeffs(T)
    p = c[end]
    for j in length(c)-1:-1:1
        p = _mf_add(_mf_mul(p, s), c[j])
    end
    e = _mf_mul(s, p)
    for _ in 1:k
        e = _mf_mul(e, _mf_add(e, (T(2), zero(T))))
    end
    return DoubleFloat{T}(e[1], e[2])
end