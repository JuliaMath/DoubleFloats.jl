@inline function add_fpfp_dd(x::T, y::T) where {T<:AbstractFloat}
    return add_2(x, y)
end

@inline function sub_fpfp_dd(x::T, y::T) where {T<:AbstractFloat}
    return sub_2(x, y)
end

@inline function mul_fpfp_dd(x::T, y::T) where {T<:AbstractFloat}
    return mul_2(x, y)
end

@inline function dvi_fpfp_dd(x::T, y::T) where {T<:AbstractFloat}
    return dvi_2(x, y)
end
