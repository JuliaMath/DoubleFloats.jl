@inline function add_fpfp_dd(::Type{E}, x::T, y::T) where {T<:AbstractFloat, E<:Emphasis}
    return add_2(x, y)
end

@inline function sub_fpfp_dd(::Type{E}, x::T, y::T) where {T<:AbstractFloat, E<:Emphasis}
    return sub_2(x, y)
end

@inline function mul_fpfp_dd(::Type{E}, x::T, y::T) where {T<:AbstractFloat, E<:Emphasis}
    return mul_2(x, y)
end

@inline function dvi_fpfp_dd(::Type{E}, x::T, y::T) where {T<:AbstractFloat, E<:Emphasis}
    return dvi_2(x, y)
end
