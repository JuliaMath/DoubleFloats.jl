@inline function add_dbdb_db(x::DoubleFloat{T}, y::DoubleFloat{T}) where {T<:AbstractFloat}
    res = DoubleFloat{T}(add_dddd_dd(HILO(x), HILO(y)))
    return !isnan(HI(res))  ? res : add_dbdb_db_nonfinite(x,y)
end

Base.:(+)(x::DoubleFloat{T}, y::Tuple{T,T}) = x + DoubleFloat{T}(y[1], y[2])
Base.:(+)(x::Tuple{T,T}, y::DoubleFloat{T}) = DoubleFloat{T}(x[1], x[2]) + y


@inline function sub_dbdb_db(x::DoubleFloat{T}, y::DoubleFloat{T}) where {T<:AbstractFloat}
    res = DoubleFloat{T}(sub_dddd_dd(HILO(x), HILO(y)))
    return !isnan(HI(res)) ? res : sub_dbdb_db_nonfinite(x,y)
end

@inline function mul_dbdb_db(x::DoubleFloat{T}, y::DoubleFloat{T}) where {T<:AbstractFloat}
    res = DoubleFloat{T}(mul_dddd_dd(HILO(x), HILO(y)))
    !isnan(HI(res))  ? res : mul_dbdb_db_nonfinite(x,y)
end

@inline function dvi_dbdb_db(x::DoubleFloat{T}, y::DoubleFloat{T}) where {T<:AbstractFloat}
    res = DoubleFloat{T}(dvi_dddd_dd(HILO(x), HILO(y)))
    !isnan(HI(res)) ? res : dvi_dbdb_db_nonfinite(x,y)
end


@inline function add_dbdb_db_nonfinite(x::DoubleFloat{T}, y::DoubleFloat{T}) where {T<:AbstractFloat}
    z = HI(x) + HI(y)
    return DoubleFloat{T}(z, zero(T))
end

@inline function sub_dbdb_db_nonfinite(x::DoubleFloat{T}, y::DoubleFloat{T}) where {T<:AbstractFloat}
    z = HI(x) - HI(y)
    return DoubleFloat{T}(z, zero(T))
end

@inline function mul_dbdb_db_nonfinite(x::DoubleFloat{T}, y::DoubleFloat{T}) where {T<:AbstractFloat}
    z = HI(x) * HI(y)
    return DoubleFloat{T}(z, zero(T))
end

@inline function dvi_dbdb_db_nonfinite(x::DoubleFloat{T}, y::DoubleFloat{T}) where {T<:AbstractFloat}
    z = div(HI(x), HI(y))
    return DoubleFloat{T}(z, zero(T))
end
