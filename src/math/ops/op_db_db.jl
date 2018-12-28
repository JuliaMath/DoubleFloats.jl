@inline function abs_db_db(x::DoubleFloat{T}) where {T<:AbstractFloat}
    return DoubleFloat{T}(abs_dd_dd(HILO(x)))
end

@inline function neg_db_db(x::DoubleFloat{T}) where {T<:AbstractFloat}
    return DoubleFloat{T}(neg_dd_dd(HILO(x)))
end

@inline function negabs_db_db(x::DoubleFloat{T}) where {T<:AbstractFloat}
    return DoubleFloat{T}(negabs_dd_dd(HILO(x)))
end

@inline function inv_db_db(x::DoubleFloat{T}) where {T<:AbstractFloat}
    return DoubleFloat{T}(inv_dd_dd(HILO(x)))
end

@inline function square_db_db(x::DoubleFloat{T}) where {T<:AbstractFloat}
    return DoubleFloat{T}(square_dd_dd(HILO(x))...)
end

@inline function cube_db_db(x::DoubleFloat{T}) where {T<:AbstractFloat}
    return DoubleFloat{T}(cube_dd_dd(HILO(x))...)
end

@inline function sqrt_db_db(x::DoubleFloat{T}) where {T<:AbstractFloat}
    return DoubleFloat{T}(sqrt_dd_dd(HILO(x)))
end

@inline function cbrt_db_db(x::DoubleFloat{T}) where {T<:AbstractFloat}
    return DoubleFloat{T}(cbrt_dd_dd(HILO(x)))
end
