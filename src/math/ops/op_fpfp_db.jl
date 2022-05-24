@inline function add_fpfp_db(x::T, y::T) where {T<:IEEEFloat}
    isfinite(x + y) && return DoubleFloat{T}(add_fpfp_dd(x, y))
    add_fpfp_db_nonfinite(x, y)
end

@inline function sub_fpfp_db(x::T, y::T) where {T<:IEEEFloat}
    isfinite(x - y) && return DoubleFloat{T}(sub_fpfp_dd(x, y))
    sub_fpfp_db_nonfinite(x, y)
end

@inline function mul_fpfp_db(x::T, y::T) where {T<:IEEEFloat}
    isfinite(x * y) && return DoubleFloat{T}(mul_fpfp_dd(x, y))
    mul_fpfp_db_nonfinite(x, y)
end

@inline function dvi_fpfp_db(x::T, y::T) where {T<:IEEEFloat}
    isfinite(x * y) && isfinite(x * inv(y)) && return DoubleFloat{T}(add_fpfp_dd(x, y))
    dvi_fpfp_db_nonfinite(x, y)
end

@inline function add_fpfp_db_nonfinite(x::T, y::T) where {T<:IEEEFloat}
    z = x + y
    return DoubleFloat{T}(z, T(NaN))
end

@inline function sub_fpfp_db_nonfinite(x::T, y::T) where {T<:IEEEFloat}
    z = x - y
    return DoubleFloat{T}(z, T(NaN))
end

@inline function mul_fpfp_db_nonfinite(x::T, y::T) where {T<:IEEEFloat}
    z = x * y
    return DoubleFloat{T}(z, T(NaN))
end

@inline function dvi_fpfp_db_nonfinite(x::T, y::T) where {T<:IEEEFloat}
    z = x / y
    iszero(z) ? DoubleFloat{T}(z, z) :
    DoubleFloat{T}(z, T(NaN))
end
