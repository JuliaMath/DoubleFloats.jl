Base.:(+)(x::DoubleFloat{T}, y::Tuple{T,T}) where {T<:IEEEFloat} = x + DoubleFloat{T}(y[1], y[2])
Base.:(+)(x::Tuple{T,T}, y::DoubleFloat{T}) where {T<:IEEEFloat} = DoubleFloat{T}(x[1], x[2]) + y

Base.:(-)(x::DoubleFloat{T}, y::Tuple{T,T}) where {T<:IEEEFloat} = x - DoubleFloat{T}(y[1], y[2])
Base.:(-)(x::Tuple{T,T}, y::DoubleFloat{T}) where {T<:IEEEFloat} = DoubleFloat{T}(x[1], x[2]) - y

Base.:(*)(x::DoubleFloat{T}, y::Tuple{T,T}) where {T<:IEEEFloat} = x * DoubleFloat{T}(y[1], y[2])
Base.:(*)(x::Tuple{T,T}, y::DoubleFloat{T}) where {T<:IEEEFloat} = DoubleFloat{T}(x[1], x[2]) * y

Base.:(/)(x::DoubleFloat{T}, y::Tuple{T,T}) where {T<:IEEEFloat} = x / DoubleFloat{T}(y[1], y[2])
Base.:(/)(x::Tuple{T,T}, y::DoubleFloat{T}) where {T<:IEEEFloat} = DoubleFloat{T}(x[1], x[2]) / y


@inline function add_dbdb_db(x::DoubleFloat{T}, y::DoubleFloat{T}) where {T<:IEEEFloat}
    isfinite(HI(x) + HI(y)) && return DoubleFloat{T}(add_dddd_dd(HILO(x), HILO(y)))
    add_dbdb_db_nonfinite(x, y)
end

@inline function sub_dbdb_db(x::DoubleFloat{T}, y::DoubleFloat{T}) where {T<:IEEEFloat}
    isfinite(HI(x) - HI(y)) && return DoubleFloat{T}(sub_dddd_dd(HILO(x), HILO(y)))
    sub_dbdb_db_nonfinite(x, y)
end

@inline function mul_dbdb_db(x::DoubleFloat{T}, y::DoubleFloat{T}) where {T<:IEEEFloat}
    isfinite(HI(x) * HI(y)) && return DoubleFloat{T}(mul_dddd_dd(HILO(x), HILO(y)))
    mul_dbdb_db_nonfinite(x, y)
end

@inline function dvi_dbdb_db(x::DoubleFloat{T}, y::DoubleFloat{T}) where {T<:IEEEFloat}
    (isinf(y) && !isinf(x)) && return (signbit(x) !== signbit(y) ? -zero(DoubleFloat{T}) : zero(DoubleFloat{T}))
    (isfinite(HI(x) * inv(HI(y)))) && return DoubleFloat{T}(dvi_dddd_dd(HILO(x), HILO(y)))
    dvi_dbdb_db_nonfinite(x, y)
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
    iszero(z) ? DoubleFloat{T}(z,z) :
                DoubleFloat{T}(z, T(NaN))
end
