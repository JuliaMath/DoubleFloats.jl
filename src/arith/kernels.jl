# Double-word kernels on tuples `(hi, lo)`. Names give the operand kinds:
# `fp` a single word, `dd` a pair as a tuple.

# --- two words in, pair out ------------------------------------------------

@inline add_fpfp_dd(x::T, y::T) where {T<:IEEEFloat} = two_sum(x, y)
@inline sub_fpfp_dd(x::T, y::T) where {T<:IEEEFloat} = two_diff(x, y)
@inline mul_fpfp_dd(x::T, y::T) where {T<:IEEEFloat} = two_prod(x, y)
@inline dvi_fpfp_dd(x::T, y::T) where {T<:IEEEFloat} = two_dvi(x, y)

# --- word and pair in, pair out --------------------------------------------

@inline function add_fpdd_dd(x::T, y::Tuple{T,T}) where {T<:IEEEFloat}
    yhi, ylo = y
    yhi, ylo = two_sum(x, yhi, ylo)
    return yhi, ylo
end

@inline function sub_fpdd_dd(x::T, y::Tuple{T,T}) where {T<:IEEEFloat}
    yhi, ylo = y
    yhi, ylo = two_diff(x, yhi, ylo)
    return yhi, ylo
end

#= not quite right?
# Algorithm 12 from Tight and rigourous error bounds.  relative error <= 5u²
@inline function mul_fpdd_dd(x::T, y::Tuple{T,T}) where T<:IEEEFloat
    yhi, ylo = y
    hi, lo = two_prod(yhi, x)
    t = ylo * x
    t = t + lo
    hi, lo = two_hilo_sum(yhi, t)
    return hi, lo
end
=#
@inline function mul_fpdd_dd(x::T, y::Tuple{T,T}) where {T<:IEEEFloat}
    return _mul_fpdd_dd(two_prod, two_sum, x, y)
end

@inline function _mul_fpdd_dd(prod::P, sum::S, x, y) where {P,S}
    hihi, hilo = prod(x, y[1])
    lohi, lolo = prod(x, y[2])
    return sum(hihi, hilo, lohi, lolo)
end

@inline function dvi_fpdd_dd(x::T, y::Tuple{T,T}) where {T<:IEEEFloat}
    yinv = inv_dd_dd(y)
    zhi, zlo = mul_fpdd_dd(x, yinv)
    return zhi, zlo
end

# --- pair in, pair out -----------------------------------------------------

# inv corrected to handle zero and nonfinite values
# (a zero low word does NOT mean the reciprocal is exact -- the correction
#  in unsafe_inv_dd_dd handles yₗₒ == 0 properly, so it must not be skipped)
@inline function inv_dd_dd(y::Tuple{T,T}) where {T<:IEEEFloat}
    yₕᵢ, yₗₒ = y
    tₕᵢ = inv(yₕᵢ)
    if !isfinite(tₕᵢ) || !isfinite(yₕᵢ) || !isfinite(yₗₒ)
        zero_error_result(tₕᵢ)
    else
        unsafe_inv_dd_dd(yₕᵢ, yₗₒ)
    end
end

# inv using Algorithms 17 and 18 from Tight and rigorous error bounds
@inline function unsafe_inv_dd_dd(yₕᵢ::T, yₗₒ::T) where {T<:IEEEFloat}
    tₕᵢ = inv(yₕᵢ)
    rₕᵢ = fma(yₕᵢ, -tₕᵢ, one(T))
    rₗₒ = -(yₗₒ * tₕᵢ)
    eₕᵢ, eₗₒ = two_hilo_sum(rₕᵢ, rₗₒ)
    dₕᵢ, dₗₒ = mul_ddfp_dd((eₕᵢ, eₗₒ), tₕᵢ)
    zₕᵢ, zₗₒ = add_ddfp_dd((dₕᵢ, dₗₒ), tₕᵢ)
    return zₕᵢ, zₗₒ
end

# branch-free hot-path variant; bit-identical for finite results.
@inline function unsafe_inv_dd_dd_(yₕᵢ::T, yₗₒ::T) where {T<:IEEEFloat}
    tₕᵢ = inv(yₕᵢ)
    rₕᵢ = fma(yₕᵢ, -tₕᵢ, one(T))
    rₗₒ = -(yₗₒ * tₕᵢ)
    eₕᵢ, eₗₒ = two_hilo_sum_(rₕᵢ, rₗₒ)
    dₕᵢ, dₗₒ = mul_ddfp_dd_((eₕᵢ, eₗₒ), tₕᵢ)
    zₕᵢ, zₗₒ = add_ddfp_dd_((dₕᵢ, dₗₒ), tₕᵢ)
    return zₕᵢ, zₗₒ
end

@inline function square_dd_dd(x::Tuple{T,T}) where {T<:IEEEFloat}
    p00, e00 = two_prod(x[1], x[1])
    e00 = fma(x[1], 2x[2], e00)
    p00, e00 = two_hilo_sum(p00, e00)
    return p00, e00
end

# branch-free hot-path variant; bit-identical for finite results.
@inline function square_dd_dd_(x::Tuple{T,T}) where {T<:IEEEFloat}
    p00, e00 = two_prod_(x[1], x[1])
    e00 = fma(x[1], 2x[2], e00)
    p00, e00 = two_hilo_sum_(p00, e00)
    return p00, e00
end

@inline function cube_dd_dd(a::Tuple{T,T}) where {T<:IEEEFloat}
    zhi, zlo = square_dd_dd(a)
    zhi, zlo = mul_dddd_dd((zhi, zlo), a)
    return zhi, zlo
end

function sqrt_dd_dd(x::Tuple{T,T}) where {T<:IEEEFloat}
    (isnan(HI(x)) | iszero(HI(x))) && return x
    signbit(HI(x)) && Base.Math.throw_complex_domainerror(:sqrt, HI(x))
    isinf(HI(x)) && return x

    return _sqrt_positive(x, sqrt)
end

# Called only after proving the high limb is positive and finite.
@inline function _sqrt_positive(x, root::F) where {F}
    ahi, alo = HILO(x)
    s = root(ahi)
    d = fma(-s, s, ahi)    # ahi=s*s+d,  same order of magnitude than alo, so we can add alo safely below:
    d += alo               #  ahi+alo = s*s+d = s*s*(1+d/(s*s))   ==> sqrt(ahi+alo) = s*sqrt(1+d/s2) approx= s*(1+d/(2s2)) = s + d/(2*s)
    d = d/(s+s)
    return s, d
end

#=
    from mpfun90.f
cuberoot(A) = A * inv(cuberootsquared(A))
invcuberootsquared(A) is found iteratively using Newton's method with a final approximation from Karp
   adjustx[k] = ((1- x[k]^3 * A^2)*x[k])/3
   x[k+1] = x[k] + adjustx[k]
    ...
   x[n-1] = x[n-2] + adjustx[n-2]
   x[n] = x[n-1] + adjustx[n-1]
   cuberoot(A) = (A * x[n]) + ((A - (A * x[n])^3)) * x[n] / 3)
# x := x - x * (x^3 - a) / (2*x^3 + y)
# x -= ( x - (z/(x*x)))*(1/3)
=#

function cbrt_dd_dd(a::Tuple{T,T}) where {T<:IEEEFloat}
    hi, lo = a
    isnan(hi) && return a
    (iszero(hi) || isinf(hi)) && return (hi, zero(T))
    # Across this window the input square and the inverse-square seed's
    # cube are well inside the Float64 exponent range.
    if T === Float64 && !(0x1p-256 <= abs(hi) <= 0x1p256)
        return _cbrt_rescaled(hi, lo)
    end
    return _cbrt_newton(a)
end

@noinline function _cbrt_rescaled(hi::Float64, lo::Float64)
    k = fld(exponent(abs(hi)), 3)
    # The scaled head has magnitude in [1, 8). Scale the limbs directly
    # because the normalizing factor itself can exceed floatmax.
    rh, rl = _cbrt_newton((ldexp(hi, -3k), ldexp(lo, -3k)))
    return ldexp(rh, k), ldexp(rl, k)
end

function _cbrt_newton(a::Tuple{T,T}) where {T<:IEEEFloat}
    a2 = mul_dddd_dd(a, a)
    one1 = one(T)
    onethird = (0.3333333333333333, 1.850371707708594e-17)

    a_inv = inv_dd_dd(a)
    tmp = cbrt(HI(a_inv))
    # initial approximation to a^(-2/3)
    x = mul_fpfp_dd(tmp, tmp)

    x3 = mul_dddd_dd(x, x)
    x3 = mul_dddd_dd(x3, x)
    x3 = mul_dddd_dd(x3, a2)
    x3 = sub_fpdd_dd(one1, x3)
    x3 = mul_dddd_dd(x3, x)
    x3 = mul_dddd_dd(x3, onethird)

    x = add_dddd_dd(x, x3)

    x3 = mul_dddd_dd(x, x)
    x3 = mul_dddd_dd(x3, x)
    x3 = mul_dddd_dd(x3, a2)
    x3 = sub_fpdd_dd(one1, x3)
    x3 = mul_dddd_dd(x3, x)
    x3 = mul_dddd_dd(x3, onethird)

    x = add_dddd_dd(x, x3)

    x3 = mul_dddd_dd(x, x)
    x3 = mul_dddd_dd(x3, x)
    x3 = mul_dddd_dd(x3, a2)
    x3 = sub_fpdd_dd(one1, x3)
    x3 = mul_dddd_dd(x3, x)
    x3 = mul_dddd_dd(x3, onethird)

    x = add_dddd_dd(x, x3)

    ax = mul_dddd_dd(a, x)

    # return ax
    #                                      amax3
    #                    ax      +     (a  -  ax^3) * x /3
    #   cuberoot(A) = (A * x[n]) + ((A - (A * x[n])^3)) * x[n] / 3)

    ax3 = mul_dddd_dd(ax, ax)
    ax3 = mul_dddd_dd(ax3, ax)
    amax3 = sub_dddd_dd(a, ax3)
    amax3 = mul_dddd_dd(amax3, x)
    amax3 = mul_dddd_dd(amax3, onethird)

    ax = add_dddd_dd(ax, amax3)

    T !== Float64 && isnan(HI(ax)) && return (cbrt(HI(a)), zero(T))
    return ax
end

# --- pair and word in, pair out --------------------------------------------

@inline function add_ddfp_dd(x::Tuple{T,T}, y::T) where {T<:IEEEFloat}
    hi, lo = x
    hi, lo = two_sum(hi, y, lo)
    return hi, lo
end

@inline function sub_ddfp_dd(x::Tuple{T,T}, y::T) where {T<:IEEEFloat}
    hi, lo = x
    hi, lo = two_sum(hi, lo, -y)
    return hi, lo
end

# Algorithm 12 from Tight and rigourous error bounds.  relative error <= 5u²
@inline function mul_ddfp_dd(x::Tuple{T,T}, y::T) where {T<:IEEEFloat}
    xhi, xlo = x
    hi, lo = two_prod(xhi, y)
    t = fma(xlo, y, lo)
    hi, lo = two_hilo_sum(hi, t)
    return hi, lo
end

# branch-free hot-path variants; bit-identical for finite results.
@inline function add_ddfp_dd_(x::Tuple{T,T}, y::T) where {T<:IEEEFloat}
    hi, lo = x
    hi, lo = two_sum3_(hi, y, lo)
    return hi, lo
end

@inline function mul_ddfp_dd_(x::Tuple{T,T}, y::T) where {T<:IEEEFloat}
    xhi, xlo = x
    hi, lo = two_prod_(xhi, y)
    t = fma(xlo, y, lo)
    hi, lo = two_hilo_sum_(hi, t)
    return hi, lo
end

@inline function dvi_ddfp_dd(x::Tuple{T,T}, y::T) where {T<:IEEEFloat}
    xhi, xlo = x
    hi = xhi / y
    if !isfinite(hi)
        return zero_error_result(hi)
    end
    uh, ul = two_prod(hi, y)
    lo = ((((xhi - uh) - ul) + xlo))/y
    hi, lo = two_hilo_sum(hi, lo)
    return hi, lo
end

# --- two pairs in, pair out ------------------------------------------------

# Algorithm 6 from Tight and rigourous error bounds. relative error < 3u²
@inline function add_dddd_dd(x::Tuple{T,T}, y::Tuple{T,T}) where {T<:IEEEFloat}
    xhi, xlo = x
    yhi, ylo = y
    hi, lo = two_sum(xhi, yhi)
    thi, tlo = two_sum(xlo, ylo)
    c = lo + thi
    hi, lo = two_hilo_sum(hi, c)
    c = tlo + lo
    hi, lo = two_hilo_sum(hi, c)
    return hi, lo
end

# Algorithm 6 from Tight and rigourous error bounds. relative error < 3u²
# reworked for subtraction
@inline function sub_dddd_dd(x::Tuple{T,T}, y::Tuple{T,T}) where {T<:IEEEFloat}
    xhi, xlo = x
    yhi, ylo = y
    hi, lo = two_diff(xhi, yhi)
    thi, tlo = two_diff(xlo, ylo)
    c = lo + thi# Algorithm 9 from Tight and rigourous error bounds. relative error <= 2u²
    hi, lo = two_hilo_sum(hi, c)
    c = tlo + lo
    hi, lo = two_hilo_sum(hi, c)
    return hi, lo
end

# Algorithm 10 from Tight and rigourous error bounds.  relative error <= 7u²
@inline function mul_dddd_dd(x::Tuple{T,T}, y::Tuple{T,T}) where {T<:IEEEFloat}
    xhi, xlo = x
    yhi, ylo = y
    hi, lo = two_prod(xhi, yhi)
    t1 = xhi * ylo
    t2 = xlo * yhi
    t = t1 + t2
    t = lo + t
    hi, lo = two_hilo_sum(hi, t)
    return hi, lo
end

# Branch-free hot-path variants of the kernels above. Bit-identical to the
# guarded versions for finite results; callers must re-check the result and
# fall back to the guarded kernel on non-finite output (see op_dbdb_db.jl).
@inline function add_dddd_dd_(x::Tuple{T,T}, y::Tuple{T,T}) where {T<:IEEEFloat}
    xhi, xlo = x
    yhi, ylo = y
    hi, lo = two_sum_(xhi, yhi)
    thi, tlo = two_sum_(xlo, ylo)
    c = lo + thi
    hi, lo = two_hilo_sum_(hi, c)
    c = tlo + lo
    hi, lo = two_hilo_sum_(hi, c)
    return hi, lo
end

@inline function sub_dddd_dd_(x::Tuple{T,T}, y::Tuple{T,T}) where {T<:IEEEFloat}
    xhi, xlo = x
    yhi, ylo = y
    hi, lo = two_diff_(xhi, yhi)
    thi, tlo = two_diff_(xlo, ylo)
    c = lo + thi
    hi, lo = two_hilo_sum_(hi, c)
    c = tlo + lo
    hi, lo = two_hilo_sum_(hi, c)
    return hi, lo
end

@inline function mul_dddd_dd_(x::Tuple{T,T}, y::Tuple{T,T}) where {T<:IEEEFloat}
    xhi, xlo = x
    yhi, ylo = y
    hi, lo = two_prod_(xhi, yhi)
    t1 = xhi * ylo
    t2 = xlo * yhi
    t = t1 + t2
    t = lo + t
    hi, lo = two_hilo_sum_(hi, t)
    return hi, lo
end

@inline function dvi_dddd_dd(x::Tuple{T,T}, y::Tuple{T,T}) where {T<:IEEEFloat}
    xhi, xlo = x
    yhi, ylo = y
    hi = xhi / yhi
    if !isfinite(hi)
        return zero_error_result(hi)
    end
    uh, ul = two_prod(hi, yhi)
    lo = ((((xhi - uh) - ul) + xlo) - hi*ylo)/yhi
    hi, lo = two_hilo_sum(hi, lo)
    return hi, lo
end

# branch-free hot-path variant; bit-identical for finite results.
@inline function dvi_dddd_dd_(x::Tuple{T,T}, y::Tuple{T,T}) where {T<:IEEEFloat}
    xhi, xlo = x
    yhi, ylo = y
    hi = xhi / yhi
    uh, ul = two_prod_(hi, yhi)
    lo = ((((xhi - uh) - ul) + xlo) - hi*ylo)/yhi
    hi, lo = two_hilo_sum_(hi, lo)
    return hi, lo
end
