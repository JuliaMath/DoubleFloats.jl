@inline function abs_db_db(x::DoubleFloat{T}) where {T<:AbstractFloat}
    hi, lo = abs_dd_dd(HILO(x))
    return DoubleFloat(hi, lo)
end

@inline function neg_db_db(x::DoubleFloat{T}) where {T<:AbstractFloat}
    hi, lo = neg_dd_dd(HILO(x))
    return DoubleFloat(hi, lo)
end

@inline function negabs_db_db(x::DoubleFloat{T}) where {T<:AbstractFloat}
    hi, lo = negabs_dd_dd(HILO(x))
    return DoubleFloat(hi, lo)
end

@inline function inv_db_db(x::DoubleFloat{T}) where {T<:AbstractFloat}
    hi, lo = inv_dd_dd(HILO(x))
    return DoubleFloat(hi, lo)
end

@inline function square_db_db(x::DoubleFloat{T}) where {T<:AbstractFloat}
    hi, lo = square_dd_dd(HILO(x))
    return DoubleFloat(hi, lo)
end

@inline function cube_db_db(x::DoubleFloat{T}) where {T<:AbstractFloat}
    hi, lo = cube_dd_dd(HILO(x))
    return DoubleFloat(hi, lo)
end

@inline function sqrt_db_db(x::DoubleFloat{T}) where {T<:AbstractFloat}
    hi, lo = sqrt_dd_dd(HILO(x))
    return DoubleFloat(hi, lo)
end

@inline function cbrt_db_db(x::DoubleFloat{T}) where {T<:AbstractFloat}
    hi, lo = cbrt_dd_dd(HILO(x))
    return DoubleFloat(hi, lo)
end
