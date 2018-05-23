@inline function add_fpfp_db(x::T, y::T) where {T<:AbstractFloat}
    return DoubleFloat(add_fpfp_dd(x, y))
end

@inline function sub_fpfp_db(x::T, y::T) where {T<:AbstractFloat}
    return DoubleFloat(sub_fpfp_dd(x, y))
end

@inline function mul_fpfp_db(x::T, y::T) where {T<:AbstractFloat}
    return DoubleFloat(mul_fpfp_dd(x, y))
end

@inline function dvi_fpfp_db(x::T, y::T) where {T<:AbstractFloat}
    return DoubleFloat(dvi_fpfp_dd(x, y))
end
