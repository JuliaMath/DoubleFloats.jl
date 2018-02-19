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

@inline function mul_ddfp_db(x::Tuple{T,T}, y::T) where {T<:AbstractFloat}
    hi, lo = x
    hi, lo = mul_2(hi, y, lo)
    return hi, lo
end

@inline function dvi_ddfp_db(x::Tuple{T,T}, y::T) where {T<:AbstractFloat}
    hi, lo = x
    yinv = inv(y)
    hi, lo = mul_2(hi, lo, yinv)
    return hi, lo
end
