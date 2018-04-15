@inline function add_fpfp_db(::Type{E}, x::T, y::T) where {T<:AbstractFloat, E<:Emphasis}
    return Double(E, add_fpfp_dd(x, y))
end

@inline function sub_fpfp_db(::Type{E}, x::T, y::T) where {T<:AbstractFloat, E<:Emphasis}
    return Double(E, sub_fpfp_dd(x, y))
end

@inline function mul_fpfp_db(::Type{E}, x::T, y::T) where {T<:AbstractFloat, E<:Emphasis}
    return Double(E, mul_fpfp_dd(x, y))
end

@inline function dvi_fpfp_db(::Type{E}, x::T, y::T) where {T<:AbstractFloat, E<:Emphasis}
    return Double(E, dvi_fpfp_dd(x, y))
end
