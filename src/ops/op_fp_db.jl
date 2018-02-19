@inline function abs_fpdb(::Type{E}, x::T) where {T<:AbstractFloat, E<:Emphasis}
    return Double(abs_fp_dd(x))
end

@inline function negabs_fp_db(::Type{E}, x::T) where {T<:AbstractFloat, E<:Emphasis}
    return Double(negabs_fp_dd(x))
end

@inline function neg_fp_db(::Type{E}, x::T) where {T<:AbstractFloat, E<:Emphasis}
    return Double(neg_fp_dd(x))
end

@inline function inv_fp_db(::Type{E}, x::T) where {T<:AbstractFloat, E<:Emphasis}
    return Double(inv_fp_dd(x))
end


@inline function powr2_fp_db(::Type{E}, x::T) where {T<:AbstractFloat, E<:Emphasis}
    return Double(powr2_fp_dd(x))
end

@inline function powr3_fp_db(::Type{E}, x::T) where {T<:AbstractFloat, E<:Emphasis}
    return Double(powr3_fp_dd(x))
end

@inline function powr4_fp_db(::Type{E}, x::T) where {T<:AbstractFloat, E<:Emphasis}
    return Double(powr4_fp_dd(x))
end

@inline function powr5_fp_db(::Type{E}, x::T) where {T<:AbstractFloat, E<:Emphasis}
    return Double(powr5_fp_dd(x))
end

@inline function powr6_fp_db(::Type{E}, x::T) where {T<:AbstractFloat, E<:Emphasis}
    return Double(powr6_fp_dd(x))   
end


@inline function root2_fp_db(::Type{E}, x::T) where {T<:AbstractFloat, E<:Emphasis}
    return Double(root2_fp_dd(x))
end

@inline function root3_fp_db(::Type{E}, x::T) where {T<:AbstractFloat, E<:Emphasis}
    return Double(root3_fp_dd(x))
end

@inline function root4_fp_db(::Type{E}, x::T) where {T<:AbstractFloat, E<:Emphasis}
    return Double(root4_fp_dd(x))
end

@inline function root5_fp_db(::Type{E}, x::T) where {T<:AbstractFloat, E<:Emphasis}
    throw(ErrorException("not implemented"))
end

@inline function root6_fp_db(::Type{E}, x::T) where {T<:AbstractFloat, E<:Emphasis}
    return Double(root6_fp_dd(x))
end
