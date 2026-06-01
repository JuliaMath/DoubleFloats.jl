@inline function add_ddfp_dd(x::Tuple{T,T}, y::T) where {T<:IEEEFloat}
    hi, lo = x
    hi, lo = two_sum(hi, y, lo)
    return hi, lo
end

@inline function sub_ddfp_dd(x::Tuple{T,T}, y::T) where {T<:IEEEFloat}
    hi, lo = x
    hi, lo = two_sum(hi, lo, -y)
    return hi, lo
end

# Algorithm 12 from Tight and rigourous error bounds.  relative error <= 5u²
@inline function mul_ddfp_dd(x::Tuple{T,T}, y::T) where T<:IEEEFloat
    xhi, xlo = x
    hi, lo = two_prod(xhi, y)
    t = fma(xlo, y, lo)
    hi, lo = two_hilo_sum(hi, t)
    return hi, lo
end

# branch-free hot-path variants; bit-identical for finite results.
@inline function add_ddfp_dd_(x::Tuple{T,T}, y::T) where {T<:IEEEFloat}
    hi, lo = x
    hi, lo = two_sum3_(hi, y, lo)
    return hi, lo
end

@inline function mul_ddfp_dd_(x::Tuple{T,T}, y::T) where T<:IEEEFloat
    xhi, xlo = x
    hi, lo = two_prod_(xhi, y)
    t = fma(xlo, y, lo)
    hi, lo = two_hilo_sum_(hi, t)
    return hi, lo
end

@inline function dvi_ddfp_dd(x::Tuple{T,T}, y::T) where {T<:IEEEFloat}
    xhi, xlo = x    
    hi = xhi / y
    if !isfinite(hi)
        return zero_error_result(hi)
    end
    uh, ul = two_prod(hi, y)
    lo = ((((xhi - uh) - ul) + xlo))/y
    hi,lo = two_hilo_sum(hi, lo)
    return hi, lo
end
