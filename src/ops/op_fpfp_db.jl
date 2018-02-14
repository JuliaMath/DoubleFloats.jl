@inline function add_fpfp_db(::Type{E}, x::T, y::T) where {T<:AbstractFloat, E<:Emphasis}
    return Double(E, add_2(x, y))
end

@inline function sub_fpfp_db(::Type{E}, x::T, y::T) where {T<:AbstractFloat, E<:Emphasis}
    return Double(E, sub_2(x, y))
end

@inline function mul_fpfp_db(::Type{E}, x::T, y::T) where {T<:AbstractFloat, E<:Emphasis}
    return Double(E, mul_2(x, y))
end

@inline function dve_fpfp_db(::Type{E}, x::T, y::T) where {T<:AbstractFloat, E<:Emphasis}
    return Double(E, dve_(x, y))
end
