@inline function add_ddfp_dd(x::Tuple{T,T}, y::T) where {T<:AbstractFloat}
    hi, lo = x
    hi, lo = add_2(hi, y, lo)
    return hi, lo
end

@inline function sub_ddfp_dd(x::Tuple{T,T}, y::T) where {T<:AbstractFloat}
    hi, lo = x
    hi, lo = add_2(hi, lo, -y)
    return hi, lo
end

@inline function mul_ddfp_dd(x::Tuple{T,T}, y::T) where {T<:AbstractFloat}
    hi, lo = x
    hihi, hilo = mul_2(y, hi)
    lohi, lolo = mul_2(y, lo)
    hi, lo = add_2(hihi, hilo, lohi, lolo)
    return hi, lo
end

@inline function dvi_ddfp_dd(x::Tuple{T,T}, y::T) where {T<:AbstractFloat}
    yinv = inv_fp_dd(y)
    zhi, zlo = mul_dddd_dd(x, yinv)
    return zhi, zlo
end
