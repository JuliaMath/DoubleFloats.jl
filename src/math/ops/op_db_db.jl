@inline function inv_db_db(x::DoubleFloat{T}) where {T<:IEEEFloat}
    zhi, zlo = inv_dd_dd((x.hi, x.lo))
    return DoubleFloat{T}(zhi, zlo)
end

@inline function square_db_db(x::DoubleFloat{T}) where {T<:IEEEFloat}
    zhi, zlo = square_dd_dd((x.hi, x.lo))
    return DoubleFloat{T}(zhi, zlo)
end

@inline function cube_db_db(x::DoubleFloat{T}) where {T<:IEEEFloat}
    zhi, zlo = cube_dd_dd((x.hi, x.lo))
    return DoubleFloat{T}(zhi, zlo)
end

@inline function sqrt_db_db(x::DoubleFloat{T}) where {T<:IEEEFloat}
    zhi, zlo = sqrt_dd_dd((x.hi, x.lo))
    return DoubleFloat{T}(zhi, zlo)
end

@inline function cbrt_db_db(x::DoubleFloat{T}) where {T<:IEEEFloat}
    return cbrt_dd_dd((x.hi, x.lo))
end
