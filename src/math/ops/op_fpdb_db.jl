@inline function add_fpdb_db(x::T, y::DoubleFloat{T}) where {T<:IEEEFloat}
    (isnotfinite(x) | isnotfinite(y)) && return add_fpdb_db_nonfinite(x,y)
    zhi, zlo = add_fpdd_dd(x, (y.hi, y.lo))
    return DoubleFloat{T}(zhi, zlo)
end

@inline function sub_fpdb_db(x::T, y::DoubleFloat{T}) where {T<:IEEEFloat}
    (isnotfinite(x) | isnotfinite(y)) && return sub_fpdb_db_nonfinite(x,y)
    zhi, zlo = sub_fpdd_dd(x, (y.hi, y.lo))
    return DoubleFloat{T}(zhi, zlo)
end

@inline function mul_fpdb_db(x::T, y::DoubleFloat{T}) where {T<:IEEEFloat}
    (isnotfinite(x) | isnotfinite(y)) && return mul_fpdb_db_nonfinite(x,y)
    zhi, zlo = mul_fpdd_dd(x, (y.hi, y.lo))
    return DoubleFloat{T}(zhi, zlo)
end

@inline function dvi_fpdb_db(x::T, y::DoubleFloat{T}) where {T<:IEEEFloat}
    (isnotfinite(x) | isnotfinite(y)) && return dvi_fpdb_db_nonfinite(x,y)
    zhi, zlo = dvi_fpdd_dd(x, (y.hi, y.lo))
    return DoubleFloat{T}(zhi, zlo)
end

@inline function add_fpdb_db_nonfinite(x::T, y::DoubleFloat{T}) where {T<:IEEEFloat}
    z = x + HI(y)
    return DoubleFloat{T}(z, z)
end

@inline function sub_fpdb_db_nonfinite(x::T, y::DoubleFloat{T}) where {T<:IEEEFloat}
    z = x - HI(y)
    return DoubleFloat{T}(z, z)
end

@inline function mul_fpdb_db_nonfinite(x::T, y::DoubleFloat{T}) where {T<:IEEEFloat}
    z = x * HI(y)
    return DoubleFloat{T}(z, z)
end

@inline function dvi_fpdb_db_nonfinite(x::T, y::DoubleFloat{T}) where {T<:IEEEFloat}
    z = x / HI(y)
    return DoubleFloat{T}(z, z)
end
