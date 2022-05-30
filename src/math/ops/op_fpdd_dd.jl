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

#=
# Algorithm 12 from Tight and rigourous error bounds.  relative error <= 5u²
modified to handle +/- Inf properly
=#
@inline function mul_fpdd_dd(x::T, y::Tuple{T,T}) where T<:IEEEFloat
    yhi, ylo = y
    hihi, hilo = two_prod(yhi, x)
    t = ylo * x
    t = t + hilo
    hi, lo = two_hilo_sum(yhi, t)
    isinf(hihi) ? (hihi, NaN) : (hi, lo)
end
#=
function mul_fpdd_dd(x::T, y::Tuple{T,T}) where T<:IEEEFloat
    hi, lo = y
    hihi, hilo = two_prod(x, hi)
    lohi, lolo = two_prod(x, lo)
    hi, lo = two_sum(hihi, hilo, lohi)
    isinf(hihi) ? (hihi, NaN) : (hi, lo)
end
=#	   


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
