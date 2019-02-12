Base.:(+)(x::DoubleFloat{T}, y::Tuple{T,T}) where {T<:IEEEFloat} = x + DoubleFloat{T}(y[1], y[2])
Base.:(+)(x::Tuple{T,T}, y::DoubleFloat{T}) where {T<:IEEEFloat} = DoubleFloat{T}(x[1], x[2]) + y

Base.:(-)(x::DoubleFloat{T}, y::Tuple{T,T}) where {T<:IEEEFloat} = x - DoubleFloat{T}(y[1], y[2])
Base.:(-)(x::Tuple{T,T}, y::DoubleFloat{T}) where {T<:IEEEFloat} = DoubleFloat{T}(x[1], x[2]) - y

Base.:(*)(x::DoubleFloat{T}, y::Tuple{T,T}) where {T<:IEEEFloat} = x * DoubleFloat{T}(y[1], y[2])
Base.:(*)(x::Tuple{T,T}, y::DoubleFloat{T}) where {T<:IEEEFloat} = DoubleFloat{T}(x[1], x[2]) * y

Base.:(/)(x::DoubleFloat{T}, y::Tuple{T,T}) where {T<:IEEEFloat} = x / DoubleFloat{T}(y[1], y[2])
Base.:(/)(x::Tuple{T,T}, y::DoubleFloat{T}) where {T<:IEEEFloat} = DoubleFloat{T}(x[1], x[2]) / y


@inline function add_dbdb_db(x::DoubleFloat{T}, y::DoubleFloat{T}) where {T<:IEEEFloat}
    (isnan(LO(x)) | isnan(LO(y))) && return add_dbdb_db_nonfinite(x,y)
    return DoubleFloat{T}(add_dddd_dd(HILO(x), HILO(y)))
end

@inline function sub_dbdb_db(x::DoubleFloat{T}, y::DoubleFloat{T}) where {T<:IEEEFloat}
    (isnan(LO(x)) | isnan(LO(y))) && return sub_dbdb_db_nonfinite(x,y)
    return DoubleFloat{T}(sub_dddd_dd(HILO(x), HILO(y)))
end

@inline function mul_dbdb_db(x::DoubleFloat{T}, y::DoubleFloat{T}) where {T<:IEEEFloat}
    (isnan(LO(x)) | isnan(LO(y))) && return mul_dbdb_db_nonfinite(x,y)
    return DoubleFloat{T}(mul_dddd_dd(HILO(x), HILO(y)))
end

@inline function dvi_dbdb_db(x::DoubleFloat{T}, y::DoubleFloat{T}) where {T<:IEEEFloat}
    (iszero(HI(y)) | isnan(LO(x)) | isnan(LO(y))) && return dvi_dbdb_db_nonfinite(x,y)
    return DoubleFloat{T}(dvi_dddd_dd(HILO(x), HILO(y)))
end

@inline function add_dbdb_db_nonfinite(x::DoubleFloat{T}, y::DoubleFloat{T}) where {T<:IEEEFloat}
    z = HI(x) + HI(y)
    return DoubleFloat{T}(z, T(NaN))
end

@inline function sub_dbdb_db_nonfinite(x::DoubleFloat{T}, y::DoubleFloat{T}) where {T<:IEEEFloat}
    z = HI(x) - HI(y)
    return DoubleFloat{T}(z, T(NaN))
end

@inline function mul_dbdb_db_nonfinite(x::DoubleFloat{T}, y::DoubleFloat{T}) where {T<:IEEEFloat}
    z = HI(x) * HI(y)
    return DoubleFloat{T}(z, T(NaN))
end

@inline function dvi_dbdb_db_nonfinite(x::DoubleFloat{T}, y::DoubleFloat{T}) where {T<:IEEEFloat}
    z = HI(x) / HI(y)
    return DoubleFloat{T}(z, T(NaN))
end
