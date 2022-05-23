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
    z = inv(HI(x))
    isfinite(z) && return DoubleFloat{T}(inv_dd_dd(HILO(x)))
    inv_db_db_nonfinite(z)
end

@inline function square_db_db(x::DoubleFloat{T}) where {T<:IEEEFloat}
    z = HI(x)^2
    isfinite(z) && return DoubleFloat{T}(square_dd_dd(HILO(x)))
    square_db_db_nonfinite(z)
end

@inline function cube_db_db(x::DoubleFloat{T}) where {T<:IEEEFloat}
    z = HI(x)^3
    isfinite(z) && return DoubleFloat{T}(cube_dd_dd(HILO(x)))
    cube_db_db_nonfinite(z)
end

@inline function sqrt_db_db(x::DoubleFloat{T}) where {T<:IEEEFloat}
    z = sqrt(HI(x))
    isfinite(z) && return DoubleFloat{T}(sqrt_dd_dd(HILO(x)))
    sqrt_db_db_nonfinite(z)
end

@inline function cbrt_db_db(x::DoubleFloat{T}) where {T<:IEEEFloat}
    z = cbrt(HI(x))
    isfinite(z) && return DoubleFloat{T}(cbrt_dd_dd(HILO(x)))
    cbrt_db_db_nonfinite(z)
end

@inline function inv_db_db_nonfinite(z::T) where {T<:IEEEFloat}
    DoubleFloat{T}(z, T(NaN))
end

@inline function square_db_db_nonfinite(z::T) where {T<:IEEEFloat}
    DoubleFloat{T}(z, T(NaN))
end

@inline function cube_db_db_nonfinite(z::T) where {T<:IEEEFloat}
    DoubleFloat{T}(z, T(NaN))
end

@inline function sqrt_db_db_nonfinite(z::T) where {T<:IEEEFloat}
    DoubleFloat{T}(z, T(NaN))
end

@inline function cbrt_db_db_nonfinite(z::T) where {T<:IEEEFloat}
    DoubleFloat{T}(z, T(NaN))
end


