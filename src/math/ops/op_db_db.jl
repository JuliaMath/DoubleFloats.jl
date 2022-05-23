@inline function abs_db_db(x::DoubleFloat{T}) where {T<:IEEEFloat}
    return DoubleFloat{T}(abs_dd_dd(HILO(x)))
end

@inline function neg_db_db(x::DoubleFloat{T}) where {T<:IEEEFloat}
    return DoubleFloat{T}(neg_dd_dd(HILO(x)))
end

@inline function negabs_db_db(x::DoubleFloat{T}) where {T<:IEEEFloat}
    return DoubleFloat{T}(negabs_dd_dd(HILO(x)))
end

@inline function inv_db_db(x::DoubleFloat{T}) where {T<:IEEEFloat}
    isfinite(1.0/HI(y)) && return DoubleFloat{T}(inv_dd_dd(HILO(x)))
    add_dd_dd_nonfinite(HILO(x))
end

@inline function square_db_db(x::DoubleFloat{T}) where {T<:IEEEFloat}
    isfinite(HI(y)^2) && return DoubleFloat{T}(square_dd_dd(HILO(x)))
    square_dd_dd_nonfinite(HILO(x))
end

@inline function cube_db_db(x::DoubleFloat{T}) where {T<:IEEEFloat}
    isfinite(HI(y)^3) && return DoubleFloat{T}(cube_dd_dd(HILO(x)))
    cube_dd_dd_nonfinite(HILO(x))
end

@inline function sqrt_db_db(x::DoubleFloat{T}) where {T<:IEEEFloat}
    isfinite(sqrt(HI(y))) && return DoubleFloat{T}(sqrt_dd_dd(HILO(x)))
    sqrt_dd_dd_nonfinite(HILO(x))
end

@inline function cbrt_db_db(x::DoubleFloat{T}) where {T<:IEEEFloat}
    isfinite(cbrt(HI(y))) && return DoubleFloat{T}(cbrt_dd_dd(HILO(x)))
    cbrt_dd_dd_nonfinite(HILO(x))
end
