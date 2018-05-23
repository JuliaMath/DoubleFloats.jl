@inline function abs_fpdb(x::T) where {T<:AbstractFloat}
    return DoubleFloat(abs_fp_dd(x))
end

@inline function negabs_fp_db(x::T) where {T<:AbstractFloat}
    return DoubleFloat(negabs_fp_dd(x))
end

@inline function neg_fp_db(x::T) where {T<:AbstractFloat}
    return DoubleFloat(neg_fp_dd(x))
end

@inline function inv_fp_db(x::T) where {T<:AbstractFloat}
    return DoubleFloat(inv_fp_dd(x))
end


@inline function powr2_fp_db(x::T) where {T<:AbstractFloat}
    return DoubleFloat(powr2_fp_dd(x))
end

@inline function powr3_fp_db(x::T) where {T<:AbstractFloat}
    return DoubleFloat(powr3_fp_dd(x))
end

@inline function powr4_fp_db(x::T) where {T<:AbstractFloat}
    return DoubleFloat(powr4_fp_dd(x))
end

@inline function powr5_fp_db(x::T) where {T<:AbstractFloat}
    return DoubleFloat(powr5_fp_dd(x))
end

@inline function powr6_fp_db(x::T) where {T<:AbstractFloat}
    return DoubleFloat(powr6_fp_dd(x))
end


@inline function root2_fp_db(x::T) where {T<:AbstractFloat}
    return DoubleFloat(root2_fp_dd(x))
end

@inline function root3_fp_db(x::T) where {T<:AbstractFloat}
    return DoubleFloat(root3_fp_dd(x))
end

@inline function root4_fp_db(x::T) where {T<:AbstractFloat}
    return DoubleFloat(root4_fp_dd(x))
end

@inline function root5_fp_db(x::T) where {T<:AbstractFloat}
    throw(ErrorException("not implemented"))
end

@inline function root6_fp_db(x::T) where {T<:AbstractFloat}
    return DoubleFloat(root6_fp_dd(x))
end
