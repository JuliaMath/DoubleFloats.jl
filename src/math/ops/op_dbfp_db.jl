@inline function add_dbfp_db(x::DoubleFloat{T}, y::T) where {T<:IEEEFloat}
    (isnotfinite(x) | isnotfinite(y)) && return add_dbfp_db_nonfinite(x,y)
    zhi, zlo = add_ddfp_dd((x.hi, x.lo), y)
    return DoubleFloat{T}(zhi, zlo)
end

@inline function sub_dbfp_db(x::DoubleFloat{T}, y::T) where {T<:IEEEFloat}
    (isnotfinite(x) | isnotfinite(y)) && return sub_dbfp_db_nonfinite(x,y)
    zhi, zlo = sub_ddfp_dd((x.hi, x.lo), y)
    return DoubleFloat{T}(zhi, zlo)
end

@inline function mul_dbfp_db(x::DoubleFloat{T}, y::T) where {T<:IEEEFloat}
    (isnotfinite(x) | isnotfinite(y)) && return mul_dbfp_db_nonfinite(x,y)
    zhi, zlo = mul_ddfp_dd((x.hi, x.lo), y)
    return DoubleFloat{T}(zhi, zlo)
end

@inline function dvi_dbfp_db(x::DoubleFloat{T}, y::T) where {T<:IEEEFloat}
    (isnotfinite(x) | isnotfinite(y)) && return dvi_dbfp_db_nonfinite(x,y)
    zhi, zlo = dvi_ddfp_dd((x.hi, x.lo), y)
    return DoubleFloat{T}(zhi, zlo)
end

@inline function add_dbfp_db_nonfinite(x::DoubleFloat{T}, y::T) where {T<:IEEEFloat}
    z = HI(x) + y
    return DoubleFloat{T}(z, z)
end

@inline function sub_dbfp_db_nonfinite(x::DoubleFloat{T}, y::T) where {T<:IEEEFloat}
    z = HI(x) - y
    return DoubleFloat{T}(z, z)
end

@inline function mul_dbfp_db_nonfinite(x::DoubleFloat{T}, y::T) where {T<:IEEEFloat}
    z = HI(x) * y
    return DoubleFloat{T}(z, z)
end

@inline function dvi_dbfp_db_nonfinite(x::DoubleFloat{T}, y::T) where {T<:IEEEFloat}
    z = HI(x) / y
    return DoubleFloat{T}(z, z)
end
