# Algorithm 6 from Tight and rigourous error bounds. relative error < 3u²
@inline function add_dddd_dd(x::Tuple{T,T}, y::Tuple{T,T}) where T<:IEEEFloat
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
@inline function sub_dddd_dd(x::Tuple{T,T}, y::Tuple{T,T}) where T<:IEEEFloat
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

# Algorithm 12 from Tight and rigourous error bounds.  relative error <= 5u²
# modified to handle +/-Inf properly
function mul_dddd_dd(x::Tuple{T,T}, y::Tuple{T,T}) where T<:IEEEFloat
    xhi, xlo = x
    yhi, ylo = y
    hihi, hilo = two_prod(xhi, yhi)
    t = xlo * ylo
    t = fma(xhi, ylo, t)
    t = fma(xlo, yhi, t)
    t = hilo + t
    hi, lo = two_hilo_sum(hihi, t)
    isinf(hihi) ? (hihi, NaN) : (hi,lo)
end

#=
# reltime 60
@inline function dvi_dddd_dd(x::Tuple{T,T}, y::Tuple{T,T}) where T<:IEEEFloat
    yinv = inv_dd_dd(y)
    hi, lo = mul_dddd_dd(x, yinv)
    return hi, lo
end
=#
# reltime 107

@inline function dvi_dddd_dd(x::Tuple{T,T}, y::Tuple{T,T}) where {T<:IEEEFloat}
    xhi, xlo = x
    yhi, ylo = y
    hi = xhi / yhi
    uh, ul = two_prod(hi, yhi)
    lo = ((((xhi - uh) - ul) + xlo) - hi*ylo)/yhi
    hi,lo = two_hilo_sum(hi, lo)
    return hi, lo
end

# reltime 40

@inline function dvi_dddd_dd_fast(x::Tuple{T,T}, y::Tuple{T,T}) where T<:IEEEFloat
    xhi, xlo = x
    yhi, ylo = y
    hi = xhi / yhi
    uh, ul = two_prod(hi, yhi)
    lo = ((((xhi - uh) - ul) + xlo) - hi*ylo)/yhi
    hi,lo = two_hilo_sum(hi, lo)
    return hi, lo
end

@inline ldexp_dd(x::Tuple{T,T}, n::Integer) where {T<:IEEEFloat} =
    (ldexp(HI(x), n), ldexp(LO(x), n))

#=
    `sqrt` and `cbrt` are from KlausC (Klaus Crusius) 2022-05-24
=#

"""
    roots_scaleexp(x::IEEEFloat)

Find integer dividable by 2 and 3 and close to exponent of x
"""
@inline roots_scaleexp(x::T) where {T<:IEEEFloat} = (frexp(x)[2] ÷ 6 ) * 6

function sqrt_dd_dd(x::Tuple{T,T}) where {T<:IEEEFloat}
    (isnan(HI(x)) | iszero(HI(x))) && return x
    signbit(HI(x)) && throw(DomainError("sqrt(x) expects x >= 0"))

    sce = roots_scaleexp(HI(x))
    x = ldexp_dd(x, -sce)

    half = T(0.5)

    r = inv(sqrt(HI(x)))
    h = ldexp_dd(x, -1)

    r2 = mul_fpfp_dd(r, r)
    hr2 = mul_dddd_dd(h, r2)
    radj = sub_fpdd_dd(half, hr2)
    radj = mul_ddfp_dd(radj, r)
    r = add_fpdd_dd(r, radj)

    r2 = mul_dddd_dd(r, r)
    hr2 = mul_dddd_dd(h, r2)
    radj = sub_fpdd_dd(half, hr2)
    radj = mul_dddd_dd(radj, r)
    r = add_dddd_dd(r, radj)

    r = mul_dddd_dd(r, x)

    return ldexp_dd(r, sce ÷ 2)
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

    sce = roots_scaleexp(HI(a))
    a = ldexp_dd(a, -sce)

    hi, lo = HILO(a)
    a2 = mul_dddd_dd(a,a)
    one1 = one(T)
    onethird = (0.3333333333333333, 1.850371707708594e-17)

    a_inv = inv_dd_dd(HILO(a))
    tmp = cbrt(HI(a_inv))
    # initial approximation to a^(-2/3)
    x = mul_fpfp_dd(tmp, tmp)

    x3 = mul_dddd_dd(x,x)
    x3 = mul_dddd_dd(x3, x)
    x3 = mul_dddd_dd(x3, a2)
    x3 = sub_fpdd_dd(one1, x3)
    x3 = mul_dddd_dd(x3, x)
    x3 = mul_dddd_dd(x3, onethird)

    x = add_dddd_dd(x, x3)

    x3 = mul_dddd_dd(x,x)
    x3 = mul_dddd_dd(x3, x)
    x3 = mul_dddd_dd(x3, a2)
    x3 = sub_fpdd_dd(one1, x3)
    x3 = mul_dddd_dd(x3, x)
    x3 = mul_dddd_dd(x3, onethird)

    x = add_dddd_dd(x, x3)

    x3 = mul_dddd_dd(x,x)
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
    return ldexp_dd(ax, sce ÷ 3)
end
