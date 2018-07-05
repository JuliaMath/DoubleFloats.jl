@inline function add_dbdb_db(x::DoubleFloat{T}, y::DoubleFloat{T}) where {T<:AbstractFloat}
    res = DoubleFloat{T}(add_dddd_dd(HILO(x), HILO(y)))
    isnan(HI(res))  ? add_dbdb_db_nonfinite(x,y) : res
end

@inline function sub_dbdb_db(x::DoubleFloat{T}, y::DoubleFloat{T}) where {T<:AbstractFloat}
    res = DoubleFloat{T}(sub_dddd_dd(HILO(x), HILO(y)))
    isnan(HI(res))  ? sub_dbdb_db_nonfinite(x,y) : res
end

@inline function mul_dbdb_db(x::DoubleFloat{T}, y::DoubleFloat{T}) where {T<:AbstractFloat}
    res = DoubleFloat{T}(mul_dddd_dd(HILO(x), HILO(y)))
    isnan(HI(res))  ? mul_dbdb_db_nonfinite(x,y) : res
end

@inline function dvi_dbdb_db(x::DoubleFloat{T}, y::DoubleFloat{T}) where {T<:AbstractFloat}
    res = DoubleFloat{T}(dvi_dddd_dd(HILO(x), HILO(y)))
    isnan(HI(res))  ? dvi_dbdb_db_nonfinite(x,y) : res
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
