@inline function add_fpdd_dd(x::T, y::Tuple{T,T}) where {T<:AbstractFloat}
    yhi, ylo = y
    yhi, ylo = add_2(x, yhi, ylo)
    return yhi, ylo
end

@inline function sub_fpdd_dd(x::T, y::Tuple{T,T}) where {T<:AbstractFloat}
    yhi, ylo = y
    yhi, ylo = sub_2(x, yhi, ylo)
    return yhi, ylo
end

@inline function mul_fpdd_dd(x::T, y::Tuple{T,T}) where {T<:AbstractFloat}
    ahi, alo = mul_2(x, HI(y))
    bhi, blo = mul_2(x, LO(y))
    zhi, zlo = add_2(ahi, bhi, alo, blo)
    return zhi, zlo
end

@inline function dvi_fpdd_dd(x::T, y::Tuple{T,T}) where {T<:AbstractFloat}
    yinv = inv_dd_dd(y)
    zhi, zlo = mul_fpdd_dd(x, yinv)
    return zhi, zlo
end

@inline function dvi_fpdd_dd_fast(x::T, y::Tuple{T,T}) where {T<:AbstractFloat}
    yinv = inv_dd_dd_fast(y)
    zhi, zlo = mul_fpdd_dd(x, yinv)
    return zhi, zlo
end
