
# Algorithm 6 from Tight and rigourous error bounds. relative error < 3u²
@inline function add_dddd_dd(x::Tuple{T,T}, y::Tuple{T,T}) where T<:AbstractFloat
    xhi, xlo = x
    yhi, ylo = y
    hi, lo = add_(xhi, yhi)
    thi, tlo = add_(xlo, ylo)
    c = lo + thi
    hi, lo = add_hilo_(hi, c)
    c = tlo + lo
    hi, lo = add_hilo_(hi, c)
    return hi, lo
end

# Algorithm 6 from Tight and rigourous error bounds. relative error < 3u²
# reworked for subtraction
@inline function sub_dddd_dd(x::Tuple{T,T}, y::Tuple{T,T}) where T<:AbstractFloat
    xhi, xlo = x
    yhi, ylo = y
    hi, lo = sub_(xhi, yhi)
    thi, tlo = sub_(xlo, ylo)
    c = lo + thi# Algorithm 9 from Tight and rigourous error bounds. relative error <= 2u²
    hi, lo = add_hilo_(hi, c)
    c = tlo + lo
    hi, lo = add_hilo_(hi, c)
    return hi, lo
end

# Algorithm 12 from Tight and rigourous error bounds.  relative error <= 5u²
@inline function mul_dddd_dd(x::Tuple{T,T}, y::Tuple{T,T}) where T<:AbstractFloat
    xhi, xlo = x
    yhi, ylo = y
    hi, lo = mul_(xhi, yhi)
    t = xlo * ylo
    t = fma(xhi, ylo, t)
    t = fma(xlo, yhi, t)
    t = lo + t
    hi, lo = add_hilo_(hi, t)
    return hi, lo
end

@inline function dvi_dddd_dd(x::Tuple{T,T}, y::Tuple{T,T}) where T<:AbstractFloat
    yinv = inv_dd_dd(y)
    hi, lo = mul_dddd_dd(x, yinv)
    return hi, lo
end
