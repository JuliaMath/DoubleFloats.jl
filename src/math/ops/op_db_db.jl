@inline function abs_db_db(x::DoubleFloat{T}) where {T<:AbstractFloat}
    return DoubleFloat(abs_dd_dd(HILO(x)))
end

@inline function neg_db_db(x::DoubleFloat{T}) where {T<:AbstractFloat}
    return DoubleFloat(neg_dd_dd(HILO(x)))
end

@inline function negabs_db_db(x::DoubleFloat{T}) where {T<:AbstractFloat}
    return DoubleFloat(negabs_dd_dd(HILO(x)))
end

@inline function inv_db_db(x::DoubleFloat{T}) where {T<:AbstractFloat}
    return DoubleFloat(inv_dd_dd(HILO(x)))
end

@inline function square_db_db(x::DoubleFloat{T}) where {T<:AbstractFloat}
    return DoubleFloat(square_dd_dd(HILO(x)))
end

@inline function cube_db_db(x::DoubleFloat{T}) where {T<:AbstractFloat}
    return DoubleFloat(cube_dd_dd(HILO(x)))
end

@inline function sqrt_db_db(x::DoubleFloat{T}) where {T<:AbstractFloat}
    return DoubleFloat(sqrt_dd_dd(HILO(x)))
end

@inline function cbrt_db_db(x::DoubleFloat{T}) where {T<:AbstractFloat}
    return DoubleFloat(cbrt_dd_dd(HILO(x)))
end
