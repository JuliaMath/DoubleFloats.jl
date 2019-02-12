@inline function abs_fpdb(x::T) where {T<:IEEEFloat}
    return DoubleFloat{T}(abs_fp_dd(x))
end

@inline function negabs_fp_db(x::T) where {T<:IEEEFloat}
    return DoubleFloat{T}(negabs_fp_dd(x))
end

@inline function neg_fp_db(x::T) where {T<:IEEEFloat}
    return DoubleFloat{T}(neg_fp_dd(x))
end

@inline function inv_fp_db(x::T) where {T<:IEEEFloat}
    return DoubleFloat{T}(inv_fp_dd(x))
end


@inline function powr2_fp_db(x::T) where {T<:IEEEFloat}
    return DoubleFloat{T}(powr2_fp_dd(x))
end

@inline function powr3_fp_db(x::T) where {T<:IEEEFloat}
    return DoubleFloat{T}(powr3_fp_dd(x))
end

@inline function powr4_fp_db(x::T) where {T<:IEEEFloat}
    return DoubleFloat{T}(powr4_fp_dd(x))
end

@inline function powr5_fp_db(x::T) where {T<:IEEEFloat}
    return DoubleFloat{T}(powr5_fp_dd(x))
end

@inline function powr6_fp_db(x::T) where {T<:IEEEFloat}
    return DoubleFloat{T}(powr6_fp_dd(x))
end


@inline function root2_fp_db(x::T) where {T<:IEEEFloat}
    return DoubleFloat{T}(root2_fp_dd(x))
end

@inline function root3_fp_db(x::T) where {T<:IEEEFloat}
    return DoubleFloat{T}(root3_fp_dd(x))
end

@inline function root4_fp_db(x::T) where {T<:IEEEFloat}
    return DoubleFloat{T}(root4_fp_dd(x))
end

@inline function root5_fp_db(x::T) where {T<:IEEEFloat}
    throw(ErrorException("not implemented"))
end

@inline function root6_fp_db(x::T) where {T<:IEEEFloat}
    return DoubleFloat{T}(root6_fp_dd(x))
end
