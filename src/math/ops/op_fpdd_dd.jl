@inline function add_fpdd_dd(x::T, y::Tuple{T,T}) where {T<:IEEEFloat}
    yhi, ylo = y
    yhi, ylo = two_sum(x, yhi, ylo)
    return yhi, ylo
end

@inline function sub_fpdd_dd(x::T, y::Tuple{T,T}) where {T<:IEEEFloat}
    yhi, ylo = y
    yhi, ylo = two_diff(x, yhi, ylo)
    return yhi, ylo
end

#= not quite right?
# Algorithm 12 from Tight and rigourous error bounds.  relative error <= 5u²
@inline function mul_fpdd_dd(x::T, y::Tuple{T,T}) where T<:IEEEFloat
    yhi, ylo = y
    hi, lo = two_prod(yhi, x)
    t = ylo * x
    t = t + lo
    hi, lo = two_hilo_sum(yhi, t)
    return hi, lo
end
=#
@inline function mul_fpdd_dd(x::T, y::Tuple{T,T}) where {T<:IEEEFloat}
    return _mul_fpdd_dd(two_prod, two_sum, x, y)
end

@inline function _mul_fpdd_dd(prod::P, sum::S, x, y) where {P,S}
    hihi, hilo = prod(x, y[1])
    lohi, lolo = prod(x, y[2])
    return sum(hihi, hilo, lohi, lolo)
end

@inline function dvi_fpdd_dd(x::T, y::Tuple{T,T}) where {T<:IEEEFloat}
    yinv = inv_dd_dd(y)
    zhi, zlo = mul_fpdd_dd(x, yinv)
    return zhi, zlo
end
