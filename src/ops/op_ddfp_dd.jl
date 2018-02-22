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
    hi, lo = mul_2(x, (y, zero(T)))
    return hi, lo
end

@inline function dvi_ddfp_dd(x::Tuple{T,T}, y::T) where {T<:AbstractFloat}
    yinv = inv(y)
    hi, lo = mul_2(x, (yinv, zero(T)))
    return hi, lo
end
