for T in (Float16, Float32)
    for func in (exp2, exp, exp10, expm1, log2, log, log10, log1p)
        func(a::DoubleFloat{T}) = DoubleFloat{T}(func(Float64(a)))
    end
end

function exp(a::DoubleFloat{Float64}) = exp2(a/Double64(0.6931471805599453, 2.3190468138462996e-17))
function exp10(a::DoubleFloat{Float64}) = exp2(a/Double64(2.302585092994046, -2.1707562233822494e-16))
function exp2(a::DoubleFloat{Float64})
    abshi = abs(Hi(a))
    isnan(a) && return a
    isinf(a) && return(signbit(a) ? zero(Double64) : a)
    iszero(HI(a)) && return one(Double64)
    if abshi > 1023.5
      return (HI(a) < 0) ? zero(Double64) : inf(Double64)
    end
    return calc_exp2(a)
end


@inline function exthorner(x, p::Tuple)
    hi, lo = p[end], zero(x)
    for i in length(p)-1:-1:1
        pi = p[i]
        prod = hi*x
        err1 = fma(hi, x, -prod)
        hi, err2 = two_sum(pi,prod)
        lo = fma(lo, x, err1 + err2)
    end
    return hi, lo
end

const coefs = Tuple(log(big(2))^n/factorial(big(n)) for n in 1:10)
const coefs_hi =  Float64.(coefs)
const coefs_lo = Float64.(coefs .- coefs_hi)

function exp_kernel(x::Float64)
    hi, lo = exthorner(x, coefs_hi)
    lo2 = evalpoly(x, coefs_lo)
    hix = hi*x
    return Double64(hix, fma(lo, x, fma(lo2, x, fma(hi, x, -hix))))
end

function _make_exp_table(size, n=1)
    t_array = zeros(Double64, 16);
    for j in 1:size
        val = 2.0^(BigFloat(j-1)/(16*n))
        t_array[j] = val
    end
    return Tuple(t_array)
end
const T1 = _make_exp_table(16)
const T2 = _make_exp_table(16, 16)

function calc_exp2(a::Double64)
    x = a.hi
    N = round(Int, 256*x)
    k = N>>8
    j1 = T1[(N&255)>>4 + 1]
    j2 = T2[N&15 + 1]
    r = fma((-1/256), N, x)
    poly = exp_kernel(r)
    poly_lo = exp_kernel(a.lo)
    e2k = exp2(k)
    lo_part = fma(poly, poly_lo, poly_lo) + poly
    ans = fma(j1*j2, lo_part, j1*j2)
    return e2k*ans
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

function Base.:(^)(r::DoubleFloat{T}, n::DoubleFloat{T}) where {T<:IEEEFloat}
   if isinteger(n)
      return r^Int(n)
   else
      return exp(n * log(r))
   end
end

function Base.:(^)(r::Int, n::DoubleFloat{T}) where {T<:IEEEFloat}
   if isinteger(n)
      return r^Int(n)
   else
      return exp(n * log(r))
   end
end


function expm1(a::Double64)
    isnan(a) && return a
    isinf(a) && return(signbit(a) ? zero(Double64) : a)
    u = exp(a)
    # temp fix of if (u == one(DoubleFloat{T}))
    if (isone(u.hi))
        a
    elseif (u-1.0 == -one(Double64))
        -one(Double64)
    else
        a*(u-1.0) / log(u)
    end
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
function mul_by_two(r::DoubleFloat{T}) where {T<:IEEEFloat}
    frhi, xphi = frexp(HI(r))
    frlo, xplo = frexp(LO(r))
    xphi += 1
    xplo += 1
    hi = ldexp(frhi, xphi)
    lo = ldexp(frlo, xplo)
    return DoubleFloat{T}(hi, lo)
end

function log(x::Double64)
    isnan(x) && return x
    isinf(x) && !signbit(x) && return x
    x === zero(Double64) && return neginf(Double64)
    y = Double64(log(HI(x)), 0.0)
    z = exp(y)
    adj = (z - x) / (z + x)
    adj = mul_by_two(adj)
    y = y - adj
    return y
end

function log1p(x::Double64)
    isnan(x) && return x
    isinf(x) && !signbit(x) && return
    u = 1.0 + x
    if u == one(Double64)
        x
    else
        log(u)*x/(u-1.0)
    end
end

function log2(x::Double64)
    isnan(x) && return x
    isinf(x) && !signbit(x) && return x
    log(x) / Double64(0.6931471805599453, 2.3190468138462996e-17)
end

function log10(x::Double64)
    isnan(x) && return x
    isinf(x) && !signbit(x) && return x
    log(x) / Double64(2.302585092994046, -2.1707562233822494e-16)
end
