@inline function add_fpdb_db(x::T, y::DoubleFloat{T}) where {T<:IEEEFloat}
    isfinite(HI(x) + HI(y)) && return DoubleFloat{T}(add_fpdd_dd(x, HILO(y)))
    add_fpdb_db_nonfinite(x, y)
end

@inline function sub_fpdb_db(x::T, y::DoubleFloat{T}) where {T<:IEEEFloat}
    isfinite(HI(x) - HI(y)) && return DoubleFloat{T}(sub_fpdd_dd(x, HILO(y)))
    sub_fpdb_db_nonfinite(x, y)
end

@inline function mul_fpdb_db(x::T, y::DoubleFloat{T}) where {T<:IEEEFloat}
    isfinite(HI(x) * HI(y)) && return DoubleFloat{T}(mul_fpdd_dd(x, HILO(y)))
    mul_fpdb_db_nonfinite(x, y)
end

@inline function dvi_fpdb_db(x::T, y::DoubleFloat{T}) where {T<:IEEEFloat}
    (isfinite(x * HI(y)) && (HI(y) !== zero(T))) && return DoubleFloat{T}(dvi_fpdd_dd(x, HILO(y)))
    dvi_fpdb_db_nonfinite(x, y)
end

@inline function add_fpdb_db_nonfinite(x::T, y::DoubleFloat{T}) where {T<:IEEEFloat}
    z = x + HI(y)
    return DoubleFloat{T}(z, T(NaN))
end

@inline function sub_fpdb_db_nonfinite(x::T, y::DoubleFloat{T}) where {T<:IEEEFloat}
    z = x - HI(y)
    return DoubleFloat{T}(z, T(NaN))
end

@inline function mul_fpdb_db_nonfinite(x::T, y::DoubleFloat{T}) where {T<:IEEEFloat}
    z = x * HI(y)
    return DoubleFloat{T}(z, T(NaN))
end

@inline function dvi_fpdb_db_nonfinite(x::T, y::DoubleFloat{T}) where {T<:IEEEFloat}
    z = x / HI(y)
    iszero(z) ? DoubleFloat{T}(z,z) :
                DoubleFloat{T}(z, T(NaN))
end
