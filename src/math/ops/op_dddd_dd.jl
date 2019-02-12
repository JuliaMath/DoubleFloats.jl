# Algorithm 6 from Tight and rigourous error bounds. relative error < 3u²
@inline function add_dddd_dd(x::Tuple{T,T}, y::Tuple{T,T}) where T<:IEEEFloat
    xhi, xlo = x
    yhi, ylo = y
    hi, lo = two_sum(xhi, yhi)
    thi, tlo = two_sum(xlo, ylo)
    c = lo + thi
    hi, lo = two_hilo_sum(hi, c)
    c = tlo + lo
    hi, lo = two_hilo_sum(hi, c)
    return hi, lo
end

# Algorithm 6 from Tight and rigourous error bounds. relative error < 3u²
# reworked for subtraction
@inline function sub_dddd_dd(x::Tuple{T,T}, y::Tuple{T,T}) where T<:IEEEFloat
    xhi, xlo = x
    yhi, ylo = y
    hi, lo = two_diff(xhi, yhi)
    thi, tlo = two_diff(xlo, ylo)
    c = lo + thi# Algorithm 9 from Tight and rigourous error bounds. relative error <= 2u²
    hi, lo = two_hilo_sum(hi, c)
    c = tlo + lo
    hi, lo = two_hilo_sum(hi, c)
    return hi, lo
end

# Algorithm 12 from Tight and rigourous error bounds.  relative error <= 5u²
@inline function mul_dddd_dd(x::Tuple{T,T}, y::Tuple{T,T}) where T<:IEEEFloat
    xhi, xlo = x
    yhi, ylo = y
    hi, lo = two_prod(xhi, yhi)
    t = xlo * ylo
    t = fma(xhi, ylo, t)
    t = fma(xlo, yhi, t)
    t = lo + t
    hi, lo = two_hilo_sum(hi, t)
    return hi, lo
end

#=
# reltime 60
@inline function dvi_dddd_dd(x::Tuple{T,T}, y::Tuple{T,T}) where T<:IEEEFloat
    yinv = inv_dd_dd(y)
    hi, lo = mul_dddd_dd(x, yinv)
    return hi, lo
end
=#
# reltime 107

@inline function dvi_dddd_dd(x::Tuple{T,T}, y::Tuple{T,T}) where {T<:IEEEFloat}
    xhi, xlo = x
    yhi, ylo = y
    hi = xhi / yhi
    uh, ul = two_prod(hi, yhi)
    lo = ((((xhi - uh) - ul) + xlo) - hi*ylo)/yhi
    hi,lo = two_hilo_sum(hi, lo)
    return hi, lo
end

# reltime 40


@inline function dvi_dddd_dd_fast(x::Tuple{T,T}, y::Tuple{T,T}) where T<:IEEEFloat
    xhi, xlo = x
    yhi, ylo = y
    hi = xhi / yhi
    uh, ul = two_prod(hi, yhi)
    lo = ((((xhi - uh) - ul) + xlo) - hi*ylo)/yhi
    hi,lo = two_hilo_sum(hi, lo)
    return hi, lo
end
