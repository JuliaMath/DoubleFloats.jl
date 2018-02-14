
@inline function add_dbdb_db(x::Double{T,E}, y::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
    xhi, xlo = HILO(x)
    yhi, ylo = HILO(y)
    xhi, xlo = add_dd_dd(xhi, xlo, yhi, ylo)
    return Double(E, xhi, xlo)
end

@inline function sub_dbdb_db(x::Double{T,E}, y::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
    xhi, xlo = HILO(x)
    yhi, ylo = HILO(y)
    xhi, xlo = sub_dd_dd(xhi, xlo, yhi, ylo)
    return Double(E, xhi, xlo)
end


@inline function mul_dbdb_db(x::Double{T,E}, y::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
    xhi, xlo = HILO(x)
    yhi, ylo = HILO(y)
    xhi, xlo = mul_dd_dd(xhi, xlo, yhi, ylo)
    return Double(E, xhi, xlo)
end

@inline function dve_dbdb_db(x::Double{T,E}, y::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
    yinv = inv_db_db(y)
    return mul_dbdb_db(x, yinv)
end

# Algorithm 6 from Tight and rigourous error bounds. relative error < 3u²
@inline function add_dd_dd(xhi::T, xlo::T, yhi::T, ylo::T) where T<:IEEEFloat
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
@inline function sub_dd_dd(xhi::T, xlo::T, yhi::T, ylo::T) where T<:IEEEFloat
    hi, lo = sub_(xhi, yhi)
    thi, tlo = sub_(xlo, ylo)
    c = lo + thi# Algorithm 9 from Tight and rigourous error bounds. relative error <= 2u²
    hi, lo = add_hilo_(hi, c)
    c = tlo + lo
    hi, lo = add_hilo_(hi, c)
    return hi, lo
end

# Algorithm 12 from Tight and rigourous error bounds.  relative error <= 5u²
@inline function mul_dd_dd(xhi::T, xlo::T, yhi::T, ylo::T) where T<:IEEEFloat
    hi, lo = mul_(xhi, yhi)
    t = xlo * ylo
    t = fma(xhi, ylo, t)
    t = fma(xlo, yhi, t)
    t = lo + t
    hi, lo = add_hilo_(hi, t)
    return hi, lo
end
