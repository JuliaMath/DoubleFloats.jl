# inv using Algorithms 17 and 18 from Tight and rigorous error bounds

function inv_dd_dd(y::Tuple{T, T}) where {T<:IEEEFloat}
   yₕᵢ, yₗₒ = y
   tₕᵢ = inv(yₕᵢ)
   rₕᵢ = fma(yₕᵢ, -tₕᵢ, one(T))
   rₗₒ = -(yₗₒ * tₕᵢ)
   eₕᵢ, eₗₒ = two_hilo_sum(rₕᵢ, rₗₒ)
   dₕᵢ, dₗₒ = mul_ddfp_dd((eₕᵢ, eₗₒ), tₕᵢ)
   zₕᵢ, zₗₒ = add_ddfp_dd((dₕᵢ, dₗₒ), tₕᵢ)
   return zₕᵢ, zₗₒ
end

@inline function square_dd_dd(x::Tuple{T,T}) where {T<:IEEEFloat}
    p00, e00 = two_prod(x[1], x[1])
    e00 = fma(x[1], 2x[2], e00)
    p00, e00 = two_hilo_sum(p00, e00)
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

    ahi, alo = HILO(x)
    s = sqrt(ahi)
    d = fma(-s, s, ahi)    # ahi=s*s+d,  same order of magnitude than alo, so we can add alo safely below:
    d += alo               #  ahi+alo = s*s+d = s*s*(1+d/(s*s))   ==> sqrt(ahi+alo) = s*sqrt(1+d/s2) approx= s*(1+d/(2s2)) = s + d/(2*s)
    d = d/(s+s)
    return s,d
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
    isnan(HI(a)) && return a
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

    isnan(HI(ax)) && return DoubleFloat{T}(cbrt(HI(a)), zero(T))  # subnormal numbers
    return ax
end
