@inline function abs_fp_dd(x::T) where {T<:IEEEFloat}
    return abs(x), zero(T)
end

@inline function negabs_fp_dd(x::T) where {T<:IEEEFloat}
    return -abs(x), zero(T)
end

@inline function neg_fp_dd(x::T) where {T<:IEEEFloat}
    return -x, zero(T)
end

@inline function inv_fp_dd(x::T) where {T<:IEEEFloat}
    hi, lo = two_inv(x)
    return hi, lo
end

@inline function square_fp_dd(a::T) where {T<:IEEEFloat}
    zhi = a * a
    zlo = fma(a, a, -zhi)
    return zhi, zlo
end

@inline function cube_fp_dd(a::T) where {T<:IEEEFloat}
    zhi, zlo = square_fp_dd(a)
    zhi, zlo = mul_dddd_dd((zhi, zlo), (a, zero(T)))
    return zhi, zlo
end


@inline function powr2_fp_dd(x::T) where {T<:IEEEFloat}
    return powr2_(x)
end

@inline function powr3_fp_dd(x::T) where {T<:IEEEFloat}
    return powr3_(x)
end

@inline function powr4_fp_dd(x::T) where {T<:IEEEFloat}
    hi, lo3 = powr3_fp_dd(x)
    hi, lo = mul_(x, hi)
    lo = fma(lo3, x, lo)
    return hi, lo
end

@inline function powr5_fp_dd(x::T) where {T<:IEEEFloat}
    hi, lo4 = powr4_fp_dd(x)
    hi, lo = mul_(x, hi)
    lo = fma(lo4, x, lo)
    return hi, lo
end

@inline function powr6_fp_dd(x::T) where {T<:IEEEFloat}
    hi, lo5 = powr5_fp_dd(x)
    hi, lo = mul_(x, hi)
    lo = fma(lo5, x, lo)
    return hi, lo
end


@inline function root2_fp_dd(x::T) where {T<:IEEEFloat}
    return two_sqrt(x)
end

@inline function root3_fp_dd(x::T) where {T<:IEEEFloat}
    return two_cbrt(x)
end

@inline function root4_fp_dd(x::T) where {T<:IEEEFloat}
     return two_sqrt(sqrt(x))
end

@inline function root5_fp_dd(x::T) where {T<:IEEEFloat}
    throw(ErrorException("not implemented"))
end

@inline function root6_fp_dd(x::T) where {T<:IEEEFloat}
    return two_cbrt(sqrt(x))
end
