@inline function add_dbfp_db(x::DoubleFloat{T}, y::T) where {T<:AbstractFloat}
    !(isfinite(x) & isfinite(y)) && return add_dbfp_db_nonfinite(x,y)
    hi, lo = add_ddfp_dd(HILO(x), y)
    return DoubleFloat(hi, lo)
end

@inline function sub_dbfp_db(x::DoubleFloat{T}, y::T) where {T<:AbstractFloat}
    !(isfinite(x) & isfinite(y)) && return sub_dbfp_db_nonfinite(x,y)
    hi, lo = sub_ddfp_dd(HILO(x), y)
    return DoubleFloat(hi, lo)
end

@inline function mul_dbfp_db(x::DoubleFloat{T}, y::T) where {T<:AbstractFloat}
    !(isfinite(x) & isfinite(y)) && return mul_dbfp_db_nonfinite(x,y)
    hi, lo = mul_ddfp_dd(HILO(x), y)
    return DoubleFloat(hi, lo)
end

@inline function dvi_dbfp_db(x::DoubleFloat{T}, y::T) where {T<:AbstractFloat}
    !(isfinite(x) & isfinite(y)) && return dvi_dbfp_db_nonfinite(x,y)
    hi, lo = dvi_ddfp_dd(HILO(x), y)
    return DoubleFloat(hi, lo)
end

@inline function add_dbfp_db_nonfinite(x::DoubleFloat{T}, y::T) where {T<:AbstractFloat}
    z = HI(x) + y
    return DoubleFloat(z, zero(T))
end

@inline function sub_dbfp_db_nonfinite(x::DoubleFloat{T}, y::T) where {T<:AbstractFloat}
    z = HI(x) - y
    return DoubleFloat(z, zero(T))
end

@inline function mul_dbfp_db_nonfinite(x::DoubleFloat{T}, y::T) where {T<:AbstractFloat}
    z = HI(x) * y
    return DoubleFloat(z, zero(T))
end

@inline function dvi_dbfp_db_nonfinite(x::DoubleFloat{T}, y::T) where {T<:AbstractFloat}
    z = div(HI(x), y)
    return DoubleFloat(z, zero(T))
end
