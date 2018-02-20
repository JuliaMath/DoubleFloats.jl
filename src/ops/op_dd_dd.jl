@inline function abs_dd_dd(x::Tuple{T,T}) where {T<:AbstractFloat}
    hi, lo = x
    if signbit(hi)
        hi = -hi
        lo = -lo
    end
    return hi, lo
end

@inline function neg_dd_dd(x::Tuple{T,T}) where {T<:AbstractFloat}
    hi, lo = x
    hi = -hi
    lo = -lo
    return hi, lo
end

@inline function negabs_dd_dd(x::Tuple{T,T}) where {T<:AbstractFloat}
    hi, lo = x
    if !signbit(hi)
        hi = -hi
        lo = -lo
    end
    return hi, lo
end


function inv_dd_dd_itr(x::Tuple{T,T}, est::Tuple{T,T}) where {T<:AbstractFloat}
    err = mul_dddd_dd(x, est)
    err = sub_dddd_dd((one(T), zero(T)), err)
    err = mul_dddd_dd(est, err)
    est = add_dddd_dd(est,err)
    return est
end
#=
function inv_dd_dd(x::Tuple{T,T}) where {T<:AbstractFloat}
    est = (inv(x[1]), zero(T))
    est = inv_dd_dd_itr(x, est)
    est = inv_dd_dd_itr(x, est)
    return est
end
=#
function inv_dd_dd(x::Tuple{T,T}) where {T<:AbstractFloat}
    return DWInvDW3(HI(x), LO(x))
end

@inline function inv_dd_dd_fast(y::Tuple{T,T}) where {T<:AbstractFloat}
    xhi, xlo = one(T), zero(T)
    yhi, ylo = y
    hi = xhi / yhi
    uh, ul = mul_2(hi, yhi)
    lo = ((((xhi - uh) - ul) + xlo) - hi*ylo)/yhi
    hi, lo = add_2(hi, lo)
    return hi, lo
end


function sqrt_dd_dd(x::Tuple{T,T}) where {T<:AbstractFloat}
    iszero(HI(x)) && return x
    signbit(HI(x)) && throw(DomainError("sqrt(x) expects x >= 0"))

    half = T(0.5)
    dhalf = Double{T,E}(half, zero(T))

    r = inv(sqrt(HI(x)))
    h = Double{T,E}(HI(x) * half, LO(x) * half)

    r2 = r * r
    hr2 = h * r2
    radj = dhalf - hr2
    radj = radj * r
    r = r + radj

    r2 = r * r
    hr2 = h * r2
    radj = dhalf - hr2
    radj = radj * r
    r = r + radj

    r = r * x

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

function cbrt_dd_dd(a::Tuple{T,T}) where {T<:AbstractFloat}
    hi, lo = HILO(a)
    a2 = mul_dddd_dd(a,a)
    one1 = one(T)
    onethird = inv(T(3.0))
    
    a_inv = inv(a)
    tmp = cbrt(HI(a_inv))
    # initial approximation to a^(-2/3)
    x = mul_fpfp_dd(tmp, tmp)

    x3 = mul_dddd_dd(x,x)
    x3 = mul_dddd_dd(x3, x)
    x3 = mul_dddd_dd(x3, a2)
    x3 = sub_fpdd_dd(one1, x3)
    x3 = mul_dddd_dd(x3, x)
    x3 = mul_ddfp_dd(x3, onethird)
    
    x = add_dddd_dd(x, x3)
    
    x3 = mul_dddd_dd(x,x)
    x3 = mul_dddd_dd(x3, x)
    x3 = mul_dddd_dd(x3, a2)
    x3 = sub_fpdd_dd(one1, x3)
    x3 = mul_dddd_dd(x3, x)
    x3 = mul_ddfp_dd(x3, onethird)
    
    x = add_dddd_dd(x, x3)
    
    ax = mul_dddd_dd(a, x)
    
    x3 = mul_dddd_dd(x,x)
    x3 = mul_dddd_dd(x3, x)
    x3 = mul_dddd_dd(x3, a)
    x3 = sub_dddd_dd(a, x3)
    x3 = mul_dddd_dd(x3, x)
    x3 = mul_ddfp_dd(x3, onethird)
    
    ax = mul_dddd_dd(ax, x3)
    return ax
end
