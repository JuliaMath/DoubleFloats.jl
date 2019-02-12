@inline function add_fpdb_db(x::T, y::DoubleFloat{T}) where {T<:IEEEFloat}
    (isnan(x) | isnan(LO(y))) && return add_fpdb_db_nonfinite(x,y)
    return DoubleFloat{T}(add_fpdd_dd(x, HILO(y)))
end

@inline function sub_fpdb_db(x::T, y::DoubleFloat{T}) where {T<:IEEEFloat}
    (isnan(x) | isnan(LO(y))) && return sub_fpdb_db_nonfinite(x,y)
    return DoubleFloat{T}(sub_fpdd_dd(x, HILO(y)))
end

@inline function mul_fpdb_db(x::T, y::DoubleFloat{T}) where {T<:IEEEFloat}
    (isnan(x) | isnan(LO(y))) && return mul_fpdb_db_nonfinite(x,y)
    return DoubleFloat{T}(mul_fpdd_dd(x, HILO(y)))
end

@inline function dvi_fpdb_db(x::T, y::DoubleFloat{T}) where {T<:IEEEFloat}
    (isnan(x) | isnan(LO(y))) && return dvi_fpdb_db_nonfinite(x,y)
    return DoubleFloat{T}(dvi_fpdd_dd(x, HILO(y)))
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
    z = div(x, HI(y))
    return DoubleFloat{T}(z, T(NaN))
end
