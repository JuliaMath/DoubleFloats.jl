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
    elseif abs(HI(a)) >= 709.0
      if (HI(a) <= -709.0)
         return zero(DoubleFloat{T})
      else # HI(a) >=  709.0
         return inf(DoubleFloat{T})
      end
    end

    return calc_exp(a)
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
    frhi, xphi = frexp(HI(r))
    frlo, xplo = frexp(LO(r))
    xphi -= 1
    xplo -= 1
    hi = ldexp(frhi, xphi)
    lo = ldexp(frlo, xplo)
    return DoubleFloat{T}(hi, lo)
end

function mul_by_two(r::DoubleFloat{T}) where {T<:IEEEFloat}
    frhi, xphi = frexp(HI(r))
    frlo, xplo = frexp(LO(r))
    xphi += 1
    xplo += 1
    hi = ldexp(frhi, xphi)
    lo = ldexp(frlo, xplo)
    return DoubleFloat{T}(hi, lo)
end

function mul_pow2(r::DoubleFloat{T}, n::Int) where {T<:IEEEFloat}
    frhi, xphi = frexp(HI(r))
    frlo, xplo = frexp(LO(r))
    xphi += n
    xplo += n
    hi = ldexp(frhi, xphi)
    lo = ldexp(frlo, xplo)
    return DoubleFloat{T}(hi, lo)
end

function mul_pwr2(r::DoubleFloat{T}, n::Real) where {T<:IEEEFloat}
    m = 2.0^n
    return DoubleFloat{T}(HI(r)*m, LO(r)*m)
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

function calc_exp(a::DoubleFloat{T}) where {T<:IEEEFloat}
    is_neg = signbit(HI(a))
    xabs = is_neg ? -a : a
    xintpart = modf(xabs)[2]
    xintpart = xintpart.hi + xintpart.lo
    xint = Int64(xintpart)
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

    # exp(xfrac)
    if HI(xfrac) < 0.5
        zfrac = exp_zero_half(xfrac)
    elseif HI(xfrac) > 0.5
        zfrac = exp_half_one(xfrac)
    else
        if LO(xfrac) == 0.0
            zfrac = DoubleFloat{T}(1.6487212707001282, -4.731568479435833e-17)
        elseif signbit(LO(xfrac))
            zfrac = exp_zero_half(xfrac)
        else
            zfrac = exp_half_one(xfrac)
        end
    end

    z = HI(zint) == zero(T) ? zfrac : zint * zfrac
    if is_neg
        z = inv(z)
    end

    return z
end

function expm1(a::DoubleFloat{T}) where {T<:IEEEFloat}
    isnan(a) && return a
    isinf(a) && return(signbit(a) ? zero(DoubleFloat{T}) : a)
    u = exp(a)
    if (u == one(DoubleFloat{T}))
        x
    elseif (u-1.0 == -one(DoubleFloat{T}))
        -one(DoubleFloat{T})
    else
        a*(u-1.0) / log(u)
    end
end

function exp2(a::DoubleFloat{T}) where {T<:IEEEFloat}
    isnan(a) && return a
    isinf(a) && return(signbit(a) ? zero(DoubleFloat{T}) : a)
    return DoubleFloat{T}(2)^a
end

function exp10(a::DoubleFloat{T}) where {T<:IEEEFloat}
    isnan(a) && return a
    isinf(a) && return(signbit(a) ? zero(DoubleFloat{T}) : a)
    return DoubleFloat{T}(10)^a
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

function log(x::DoubleFloat{T}) where {T<:IEEEFloat}
    isnan(x) && return x
    isinf(x) && !signbit(x) && return x
    x === zero(DoubleFloat{T}) && return neginf(DoubleFloat{T})
    y = DoubleFloat(log(HI(x)), zero(T))
    z = exp(y)
    adj = (z - x) / (z + x)
    adj = mul_by_two(adj)
    y = y - adj
    return y
end


function log1p(x::DoubleFloat{T})  where {T<:IEEEFloat}
    isnan(x) && return x
    isinf(x) && !signbit(x) && return 
    u = 1.0 + x
    if u == one(DoubleFloat{T})
        x
    else
        log(u)*x/(u-1.0)
    end
end

logten(::Type{DoubleFloat{Float64}}) = Double64(2.302585092994046, -2.1707562233822494e-16)
logtwo(::Type{DoubleFloat{Float64}}) = Double64(0.6931471805599453, 2.3190468138462996e-17)
logtwo(::Type{DoubleFloat{Float32}}) = Double32(0.6931472, -1.9046542e-9)
logten(::Type{DoubleFloat{Float32}}) = Double32(2.3025851, -3.1975436e-8)
logtwo(::Type{DoubleFloat{Float16}}) = Double16(0.6934, -0.0002122)
logten(::Type{DoubleFloat{Float16}}) = Double16(2.303, -0.0001493)

function log2(x::DoubleFloat{T}) where {T<:IEEEFloat}
    isnan(x) && return x
    isinf(x) && !signbit(x) && return x
    log(x) / logtwo(DoubleFloat{T})
end

function log10(x::DoubleFloat{T}) where {T<:IEEEFloat}
    isnan(x) && return x
    isinf(x) && !signbit(x) && return x
    log(x) / logten(DoubleFloat{T})
end
