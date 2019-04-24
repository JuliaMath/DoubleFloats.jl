@inline function add_ddfp_dd(x::Tuple{T,T}, y::T) where {T<:IEEEFloat}
    hi, lo = x
    hi, lo = two_sumof3(hi, y, lo)
    return hi, lo
end

@inline function sub_ddfp_dd(x::Tuple{T,T}, y::T) where {T<:IEEEFloat}
    hi, lo = x
    hi, lo = two_sumof3(hi, lo, -y)
    return hi, lo
end

#=
@inline function mul_ddfp_dd(x::Tuple{T,T}, y::T) where {T<:IEEEFloat}
    hi, lo = x
    hihi, hilo = two_prod(y, hi)
    lohi, lolo = two_prod(y, lo)
    hi, lo = two_sumof4(hihi, hilo, lohi, lolo)
    return hi, lo
end
=#

# Algorithm 12 from Tight and rigourous error bounds.  relative error <= 5u²
@inline function mul_ddfp_dd(x::Tuple{T,T}, y::T) where T<:IEEEFloat
    xhi, xlo = x
    hi, lo = two_prod(xhi, y)
    t = xlo * y
    t = t + lo
    hi, lo = two_hilo_sum(hi, t)
    return hi, lo
end

@inline function dvi_ddfp_dd(x::Tuple{T,T}, y::T) where {T<:IEEEFloat}
    xhi, xlo = x    
    hi = xhi / y
    uh, ul = two_prod(hi, y)
    lo = ((((xhi - uh) - ul) + xlo))/y
    hi,lo = two_hilo_sum(hi, lo)
    return hi, lo
end
