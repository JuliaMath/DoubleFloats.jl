@inline function add_fpdd_dd(x::T, y::Tuple{T,T}) where {T<:IEEEFloat}
    yhi, ylo = y
    yhi, ylo = two_sumof3(x, yhi, ylo)
    return yhi, ylo
end

@inline function sub_fpdd_dd(x::T, y::Tuple{T,T}) where {T<:IEEEFloat}
    yhi, ylo = y
    yhi, ylo = two_diffof3(x, yhi, ylo)
    return yhi, ylo
end

@inline function mul_fpdd_dd(x::T, y::Tuple{T,T}) where {T<:IEEEFloat}
    hi, lo = y
    hihi, hilo = two_prod(x, hi)
    lohi, lolo = two_prod(x, lo)
    hi, lo = two_sumof4(hihi, hilo, lohi, lolo)
    return hi, lo
end

@inline function dvi_fpdd_dd(x::T, y::Tuple{T,T}) where {T<:IEEEFloat}
    yinv = inv_dd_dd(y)
    zhi, zlo = mul_fpdd_dd(x, yinv)
    return zhi, zlo
end

@inline function dvi_fpdd_dd_fast(x::T, y::Tuple{T,T}) where {T<:IEEEFloat}
    yinv = inv_dd_dd_fast(y)
    zhi, zlo = mul_fpdd_dd(x, yinv)
    return zhi, zlo
end
