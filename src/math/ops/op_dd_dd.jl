@inline function abs_dd_dd(x::Tuple{T,T}) where {T<:IEEEFloat}
    hi, lo = x
    if signbit(hi)
        hi = -hi
        lo = -lo
    end
    return hi, lo
end

@inline function neg_dd_dd(x::Tuple{T,T}) where {T<:IEEEFloat}
    hi, lo = x
    hi = -hi
    lo = -lo
    return hi, lo
end

@inline function negabs_dd_dd(x::Tuple{T,T}) where {T<:IEEEFloat}
    hi, lo = x
    if !signbit(hi)
        hi = -hi
        lo = -lo
    end
    return hi, lo
end

function inv_dd_dd(x::Tuple{T,T}) where {T<:IEEEFloat}
    return DWInvDW3(HI(x), LO(x))
end
function inv_dd_dd_fast(x::Tuple{T,T}) where {T<:IEEEFloat}
    return DWInvDW2(HI(x), LO(x))
end

#=
   slightly faster than inv_dd_dd_fast, without analytic relerr though
@inline function inv_dd_dd_fast(y::Tuple{T,T}) where {T<:IEEEFloat}
    xhi, xlo = one(T), zero(T)
    yhi, ylo = y
    hi = xhi / yhi
    uh, ul = two_prod(hi, yhi)
    lo = ((((xhi - uh) - ul) + xlo) - hi*ylo)/yhi
    hi, lo = two_sum(hi, lo)
    return hi, lo
end
=#
@inline function square_dd_dd(a::Tuple{T,T}) where {T<:IEEEFloat}
    ahi, alo = HILO(a)
    zhi = ahi * ahi
    zlo = fma(ahi, ahi, -zhi)
    zlo += (ahi * alo) * 2
    zlo += alo * alo
    return zhi, zlo
end

@inline function cube_dd_dd(a::Tuple{T,T}) where {T<:IEEEFloat}
    zhi, zlo = square_dd_dd(a)
    zhi, zlo = mul_dddd_dd((zhi, zlo), a)
    return zhi, zlo
end


function sqrt_dd_dd(x::Tuple{T,T}) where {T<:IEEEFloat}
    (isnan(HI(x)) | iszero(HI(x))) && return x
    signbit(HI(x)) && throw(DomainError("sqrt(x) expects x >= 0"))

    half = T(0.5)
    dhalf = (half, zero(T))

    r = inv(sqrt(HI(x)))
    h = (HI(x) * half, LO(x) * half)

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

    return r
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
    hi, lo = HILO(a)
    a2 = mul_dddd_dd(a,a)
    one1 = one(T)
    onethird = (0.3333333333333333, 1.850371707708594e-17)

    a_inv = inv_dd_dd(a)
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
    return ax
end
