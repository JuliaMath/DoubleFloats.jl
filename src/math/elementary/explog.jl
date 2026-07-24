# ---------------------------------------------------------------------------
# MultiFloats v3.0 double-word kernels (mfadd/mfmul/mfsqr/mfdiv, N = 2),
# operating on (hi, lo) tuples.  two_sum / two_hilo_sum / two_prod are the
# error-free transformations already defined in math/errorfree.jl.
# ---------------------------------------------------------------------------

@inline function _mf_add(x::Tuple{T,T}, y::Tuple{T,T}) where {T<:IEEEFloat}
    a, b = two_sum(x[1], y[1])
    c, d = two_sum(x[2], y[2])
    a, c = two_hilo_sum(a, c)
    b += d
    b += c
    return two_hilo_sum(a, b)
end

@inline function _mf_mul(x::Tuple{T,T}, y::Tuple{T,T}) where {T<:IEEEFloat}
    p, e = two_prod(x[1], y[1])
    e += x[1] * y[2] + x[2] * y[1]
    return two_hilo_sum(p, e)
end

@inline function _mf_sqr(x::Tuple{T,T}) where {T<:IEEEFloat}
    p, e = two_prod(x[1], x[1])
    e = fma(x[1], x[2] + x[2], e)
    return two_hilo_sum(p, e)
end

# reciprocal-based (Karp–Markstein): differs from dvi_dddd_dd, which divides.
@inline function _mf_div(x::Tuple{T,T}, y::Tuple{T,T}) where {T<:IEEEFloat}
    w = inv(y[1])
    z = x[1] * w
    p, e = two_prod(y[1], z)
    r = ((x[1] - p) - e) + fma(-y[2], z, x[2])
    return two_hilo_sum(z, r * w)
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

## 3. The `exp2` / `exp` / `exp10` family

### Constants

# clamp bounds on the leading limb of the base-2 argument (exp.jl:1)
@inline _exp2_min(::Type{Float64}) = -0x1.FF00000000000p+0009   # -1022.0
@inline _exp2_max(::Type{Float64}) = +0x1.FFFFFFFFFFFFFp+0009   # ~1024.0
@inline _exp2_min(::Type{Float32}) = Float32(-0x1.F80000p+006)  # -126.0f0
@inline _exp2_max(::Type{Float32}) = Float32(+0x1.FFFFFEp+006)  # ~128.0f0

# 2-limb base-conversion constants (heads of the MultiFloats full tables)
@inline _log2_e(::Type{Float64}) =
    (+0x1.71547652B82FEp+0000, +0x1.777D0FFDA0D24p-0056)
@inline _log2_10(::Type{Float64}) =
    (+0x1.A934F0979A371p+0001, +0x1.7F2495FB7FA6Dp-0053)
@inline _log2_e(::Type{Float32}) =
    (Float32(+0x1.715476p+000), Float32(+0x1.4AE0C0p-026))
@inline _log2_10(::Type{Float32}) =
    (Float32(+0x1.A934F0p+001), Float32(+0x1.2F346Ep-024))

### Polynomial kernels

#=
Tapered minimax approximations of `2^r` on `|r| ≤ 1/16`; coefficients
≈ `(ln 2)^k / k!`. `Float64`: degree 13, 9 double-word + 5 scalar terms
(`exp.jl:68`). `Float32`: degree 7, 5 + 3 (`exp.jl:15`).
=#

@inline function _exp2_poly(r::Tuple{Float64,Float64})
    r1 = r[1]
    t = +0x1.816519F74C4AFp-0040                       # c14
    t = t * r1 + 0x1.C3C1919538484p-0036               # c13
    t = t * r1 + 0x1.E8CAC72F6E9E5p-0032               # c12
    t = t * r1 + 0x1.E4CF5152FBB30p-0028               # c11
    t = t * r1 + 0x1.B5253D395E80Fp-0024               # c10
    p = (t, 0.0)
    p = _mf_add(_mf_mul(p, r), (+0x1.62C0223A5C863p-0020, -0x1.99EF542AA8E1Ep-0074))  # c9
    p = _mf_add(_mf_mul(p, r), (+0x1.FFCBFC588B0C7p-0017, -0x1.E645E286FE571p-0071))  # c8
    p = _mf_add(_mf_mul(p, r), (+0x1.430912F86C787p-0013, +0x1.BC7CDBCDC0339p-0067))  # c7
    p = _mf_add(_mf_mul(p, r), (+0x1.5D87FE78A6731p-0010, +0x1.0717F88815ADFp-0066))  # c6
    p = _mf_add(_mf_mul(p, r), (+0x1.3B2AB6FBA4E77p-0007, +0x1.4E65DFEF67D34p-0062))  # c5
    p = _mf_add(_mf_mul(p, r), (+0x1.C6B08D704A0C0p-0005, -0x1.D3316275139AEp-0059))  # c4
    p = _mf_add(_mf_mul(p, r), (+0x1.EBFBDFF82C58Fp-0003, -0x1.5E43A53E454F1p-0057))  # c3
    p = _mf_add(_mf_mul(p, r), (+0x1.62E42FEFA39EFp-0001, +0x1.ABC9E3B39803Fp-0056))  # c2
    p = _mf_add(_mf_mul(p, r), (+0x1.0000000000000p+0000, +0x1.314BACF0323FFp-0113))  # c1
    return p
end

@inline function _exp2_poly(r::Tuple{Float32,Float32})
    r1 = r[1]
    t = Float32(+0x1.FFD486p-017)                      # d8
    t = t * r1 + Float32(+0x1.430E9Ep-013)             # d7
    t = t * r1 + Float32(+0x1.5D87FEp-010)             # d6
    p = (t, 0.0f0)
    p = _mf_add(_mf_mul(p, r), (Float32(+0x1.3B2AB6p-007), Float32(+0x1.DB9286p-032)))  # d5
    p = _mf_add(_mf_mul(p, r), (Float32(+0x1.C6B08Ep-005), Float32(-0x1.1F6B9Cp-030)))  # d4
    p = _mf_add(_mf_mul(p, r), (Float32(+0x1.EBFBE0p-003), Float32(-0x1.F4DEB0p-033)))  # d3
    p = _mf_add(_mf_mul(p, r), (Float32(+0x1.62E430p-001), Float32(-0x1.05C610p-029)))  # d2
    p = _mf_add(_mf_mul(p, r), (Float32(+0x1.000000p+000), Float32(-0x1.62C458p-059)))  # d1
    return p
end

### Kernel and public methods

@inline function _exp2_kernel(x::Tuple{T,T}) where {T<:IEEEFloat}
    _half   = T(0.5)
    _eighth = T(0.125)
    # reduction: x = n + 8r, n integer, |r| ≤ 1/16              (exact)
    # trunc-based nearest-integer: reproducible across CPU/GPU backends
    n_float = trunc(x[1] + copysign(_half, x[1]))
    r = _mf_add(x, (-n_float, zero(T)))
    r = (_eighth * r[1], _eighth * r[2])
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

@inline function _exp2_clamped(x::Tuple{T,T}) where {T<:IEEEFloat}
    p = _exp2_kernel(x)
    p = ifelse(x[1] < _exp2_min(T), (zero(T), zero(T)), p)
    p = ifelse(x[1] > _exp2_max(T), (T(Inf), T(Inf)), p)
    return p
end

const _DF64or32 = Union{Float64, Float32}

function Base.exp2(x::DoubleFloat{T}) where {T<:_DF64or32}
    p = _exp2_clamped(HILO(x))
    return DoubleFloat{T}(p[1], p[2])
end

function Base.exp(x::DoubleFloat{T}) where {T<:_DF64or32}
    p = _exp2_clamped(_mf_mul(HILO(x), _log2_e(T)))
    return DoubleFloat{T}(p[1], p[2])
end

function Base.exp10(x::DoubleFloat{T}) where {T<:_DF64or32}
    p = _exp2_clamped(_mf_mul(HILO(x), _log2_10(T)))
    return DoubleFloat{T}(p[1], p[2])
end

#=
Behavioral notes versus the current DoubleFloats implementation:

- NaN propagates through `n_float` and the polynomial naturally; `-Inf`
  hits the low clamp → `0.0`; `+Inf` hits the high clamp →
  `inf(DoubleFloat{T})`. No explicit guards needed.
- **Subnormal outputs are flushed to zero**: `exp2` arguments in
  `[-1074, -1022)` (`Double64`) / `[-149, -126)` (`Double32`) return `0`
  rather than a subnormal-`hi` result. The current DoubleFloats `exp`
  goes through a `Float128` path to cover roughly `[-745, -600]`; if
  that behavior must be preserved, keep the existing guard as a
  pre-check and fall through to this kernel otherwise.
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

# 32-entry lookup table: centers 1 + (2i-1)/64 (exact in T) and log2(center)
# as (hi, lo) pairs, generated at load time (log.jl:185)
for (T, prec) in ((Float64, 160), (Float32, 80))
    centers = ntuple(i -> T(1 + (2i - 1) // 64), 32)
    values = ntuple(32) do i
        b = setprecision(() -> log2(Float128(centers[i])), Float128, prec)
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
    t = t * u1 + 0x1.0C9A845FCF968p-0002               # k6
    t = t * u1 + 0x1.484B13D7C0C4Dp-0002               # k5
    p = (t, 0.0)
    p = _mf_add(_mf_mul(p, u), (+0x1.A61762A7ADED9p-0002, +0x1.90D60ECEBE07Fp-0057))  # k4
    p = _mf_add(_mf_mul(p, u), (+0x1.2776C50EF9BFEp-0001, +0x1.E4B2AE3DCBD87p-0055))  # k3
    p = _mf_add(_mf_mul(p, u), (+0x1.EC709DC3A03FDp-0001, +0x1.D27F055486A5Ap-0055))  # k2
    p = _mf_add(_mf_mul(p, u), (+0x1.71547652B82FEp+0001, +0x1.777D0FFDA0D24p-0055))  # k1
    return p
end

@inline function _log2_poly_wide(u::Tuple{Float64,Float64})
    u1 = u[1]
    t = +0x1.5D108CD7E21EBp-0003                       # w9
    t = t * u1 + 0x1.89F2F69137330p-0003               # w8
    t = t * u1 + 0x1.C68F56BF8A8ACp-0003               # w7
    p = (t, 0.0)
    p = _mf_add(_mf_mul(p, u), (+0x1.0C9A84993C2EEp-0002, +0x1.0E0FE2C5542A6p-0056))  # w6
    p = _mf_add(_mf_mul(p, u), (+0x1.484B13D7C02AFp-0002, -0x1.9282874496178p-0057))  # w5
    p = _mf_add(_mf_mul(p, u), (+0x1.A61762A7ADED9p-0002, +0x1.F8B804528988Ap-0057))  # w4
    p = _mf_add(_mf_mul(p, u), (+0x1.2776C50EF9BFEp-0001, +0x1.E4B2A0D0290E2p-0055))  # w3
    p = _mf_add(_mf_mul(p, u), (+0x1.EC709DC3A03FDp-0001, +0x1.D27F055480ABFp-0055))  # w2
    p = _mf_add(_mf_mul(p, u), (+0x1.71547652B82FEp+0001, +0x1.777D0FFDA0D24p-0055))  # w1
    return p
end

@inline function _log2_poly_narrow(u::Tuple{Float32,Float32})
    t = Float32(+0x1.A6217Cp-002)                      # k4
    t = t * u[1] + Float32(+0x1.2776C6p-001)           # k3
    p = (t, 0.0f0)
    p = _mf_add(_mf_mul(p, u), (Float32(+0x1.EC709Ep-001), Float32(-0x1.E2FDB2p-028)))  # k2
    p = _mf_add(_mf_mul(p, u), (Float32(+0x1.715476p+001), Float32(+0x1.4AE0C0p-025)))  # k1
    return p
end

@inline function _log2_poly_wide(u::Tuple{Float32,Float32})
    t = Float32(+0x1.48FE3Ap-002)                      # w5
    t = t * u[1] + Float32(+0x1.A61738p-002)           # w4
    p = (t, 0.0f0)
    p = _mf_add(_mf_mul(p, u), (Float32(+0x1.2776C6p-001), Float32(-0x1.DE12AAp-026)))  # w3
    p = _mf_add(_mf_mul(p, u), (Float32(+0x1.EC709Ep-001), Float32(-0x1.E2FE88p-028)))  # w2
    p = _mf_add(_mf_mul(p, u), (Float32(+0x1.715476p+001), Float32(+0x1.4AE0C0p-025)))  # w1
    return p
end

### Kernel and public methods

@inline function _unsafe_log2(x::Tuple{T,T}) where {T<:IEEEFloat}
    _one = one(T)
    _zero = zero(T)
    # exact split: x = 2^e · m,  m₁ ∈ [1, 2)
    e = _raw_exponent(x[1])
    m = (_uldexp(x[1], -e), _uldexp(x[2], -e))
    i = _log2_index(x[1]) + 1
    c = _log2_centers(T)[i]
    v = _log2_values(T)[i]

    # both paths, branch-free; numerators are Sterbenz-exact
    t_dir = _mf_div(_mf_add(x, (-_one, _zero)), _mf_add(x, (_one, _zero)))
    t_tab = _mf_div(_mf_add(m, (-c, -_zero)), _mf_add(m, (c, _zero)))
    direct = _mf_mul(t_dir, _log2_poly_wide(_mf_sqr(t_dir)))
    tabled = _mf_add(_mf_add((T(e), _zero), v),
                     _mf_mul(t_tab, _log2_poly_narrow(_mf_sqr(t_tab))))

    near_one = (T(0.9375) < x[1]) & (x[1] < T(1.0625))  # 15/16 < x₁ < 17/16
    return ifelse(near_one, direct, tabled)
end

@inline function _log_special(x::Tuple{T,T}, y::Tuple{T,T}) where {T<:IEEEFloat}
    y = ifelse(iszero(x[1]) & iszero(x[2]), (T(-Inf), T(-Inf)), y)
    y = ifelse(isinf(x[1]) & !signbit(x[1]), (T(Inf), T(Inf)), y)
    y = ifelse(isnan(x[1]) | (signbit(x[1]) & !iszero(x[1])),
        (T(NaN), T(NaN)), y)
    return y
end

function Base.log2(x::DoubleFloat{T}) where {T<:_DF64or32}
    t = HILO(x)
    y = _log_special(t, _unsafe_log2(t))
    return DoubleFloat{T}(y[1], y[2])
end

function Base.log(x::DoubleFloat{T}) where {T<:_DF64or32}
    t = HILO(x)
    y = _log_special(t, _mf_mul(_unsafe_log2(t), _ln_2(T)))
    return DoubleFloat{T}(y[1], y[2])
end

function Base.log10(x::DoubleFloat{T}) where {T<:_DF64or32}
    t = HILO(x)
    y = _log_special(t, _mf_mul(_unsafe_log2(t), _log10_2(T)))
    return DoubleFloat{T}(y[1], y[2])
end
