@inline function add_dbfp_db(x::Double{T,E}, y::T) where {T<:AbstractFloat, E<:Emphasis}
    !(isfinite(x) & isfinite(y)) && return add_dbfp_db_nonfinite(x,y)
    hi, lo = add_ddfp_dd(HILO(x), y)
    return Double(E, hi, lo)
end

@inline function sub_dbfp_db(x::Double{T,E}, y::T) where {T<:AbstractFloat, E<:Emphasis}
    !(isfinite(x) & isfinite(y)) && return sub_dbfp_db_nonfinite(x,y)
    hi, lo = sub_ddfp_dd(HILO(x), y)
    return Double(E, hi, lo)
end

@inline function mul_dbfp_db(x::Double{T,E}, y::T) where {T<:AbstractFloat, E<:Emphasis}
    !(isfinite(x) & isfinite(y)) && return mul_dbfp_db_nonfinite(x,y)
    hi, lo = mul_ddfp_dd(HILO(x), y)
    return Double(E, hi, lo)
end

@inline function dvi_dbfp_db(x::Double{T,E}, y::T) where {T<:AbstractFloat, E<:Emphasis}
    !(isfinite(x) & isfinite(y)) && return dvi_dbfp_db_nonfinite(x,y)
    hi, lo = dvi_ddfp_dd(HILO(x), y)
    return Double(E, hi, lo)
end

@inline function add_dbfp_db_nonfinite(x::Double{T,E}, y::T) where {T<:AbstractFloat, E<:Emphasis}
    z = HI(x) + y
    return Double(E, z, zero(Double{T,E}))
end

@inline function sub_dbfp_db_nonfinite(x::Double{T,E}, y::T) where {T<:AbstractFloat, E<:Emphasis}
    z = HI(x) - y
    return Double(E, z, zero(Double{T,E}))
end

@inline function mul_dbfp_db_nonfinite(x::Double{T,E}, y::T) where {T<:AbstractFloat, E<:Emphasis}
    z = HI(x) * y
    return Double(E, z, zero(Double{T,E}))
end

@inline function dvi_dbfp_db_nonfinite(x::Double{T,E}, y::T) where {T<:AbstractFloat, E<:Emphasis}
    z = div(HI(x), y)
    return Double(E, z, zero(Double{T,E}))
end
