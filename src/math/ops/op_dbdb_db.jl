@inline function add_dbdb_db(x::DoubleFloat{T}, y::DoubleFloat{T}) where {T<:AbstractFloat}
    !(isfinite(x) & isfinite(y)) && return add_dbdb_db_nonfinite(x,y)
    hi, lo = add_dddd_dd(HILO(x), HILO(y))
    return DoubleFloat(hi, lo)
end

@inline function sub_dbdb_db(x::DoubleFloat{T}, y::DoubleFloat{T}) where {T<:AbstractFloat}
    !(isfinite(x) & isfinite(y)) && return sub_dbdb_db_nonfinite(x,y)
    hi, lo = sub_dddd_dd(HILO(x), HILO(y))
    return DoubleFloat(hi, lo)
end

@inline function mul_dbdb_db(x::DoubleFloat{T}, y::DoubleFloat{T}) where {T<:AbstractFloat}
    !(isfinite(x) & isfinite(y)) && return mul_dbdb_db_nonfinite(x,y)
    hi, lo = mul_dddd_dd(HILO(x), HILO(y))
    return DoubleFloat(hi, lo)
end

@inline function dvi_dbdb_db(x::DoubleFloat{T}, y::DoubleFloat{T}) where {T<:AbstractFloat}
    !(isfinite(x) & isfinite(y)) && return dvi_dbdb_db_nonfinite(x,y)
    hi, lo = dvi_dddd_dd(HILO(x), HILO(y))
    return DoubleFloat(hi, lo)
end


@inline function add_dbdb_db_nonfinite(x::DoubleFloat{T}, y::DoubleFloat{T}) where {T<:AbstractFloat}
    z = HI(x) + HI(y)
    return DoubleFloat(z, zero(T))
end

@inline function sub_dbdb_db_nonfinite(x::DoubleFloat{T}, y::DoubleFloat{T}) where {T<:AbstractFloat}
    z = HI(x) - HI(y)
    return DoubleFloat(z, zero(T))
end

@inline function mul_dbdb_db_nonfinite(x::DoubleFloat{T}, y::DoubleFloat{T}) where {T<:AbstractFloat}
    z = HI(x) * HI(y)
    return DoubleFloat(z, zero(T))
end

@inline function dvi_dbdb_db_nonfinite(x::DoubleFloat{T}, y::DoubleFloat{T}) where {T<:AbstractFloat}
    z = div(HI(x), HI(y))
    return DoubleFloat(z, zero(T))
end
