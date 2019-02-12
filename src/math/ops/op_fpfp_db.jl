@inline function add_fpfp_db(x::T, y::T) where {T<:IEEEFloat}
    return DoubleFloat{T}(add_fpfp_dd(x, y))
end

@inline function sub_fpfp_db(x::T, y::T) where {T<:IEEEFloat}
    return DoubleFloat{T}(sub_fpfp_dd(x, y))
end

@inline function mul_fpfp_db(x::T, y::T) where {T<:IEEEFloat}
    return DoubleFloat{T}(mul_fpfp_dd(x, y))
end

@inline function dvi_fpfp_db(x::T, y::T) where {T<:IEEEFloat}
    return DoubleFloat{T}(dvi_fpfp_dd(x, y))
end
