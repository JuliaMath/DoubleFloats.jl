@inline function inv_db_db(x::DoubleFloat{T}) where {T<:IEEEFloat}
    yhi, ylo = x.hi, x.lo
    thi = inv(yhi)
    # See the comment on inv_dd_dd: ylo == 0 must not short-circuit, or inv loses
    # the low word for every exactly-representable argument (e.g. inv(Double64(3))).
    (!isfinite(thi) || !isfinite(yhi) || !isfinite(ylo)) &&
        return DoubleFloat{T}(zero_error_result(thi)...)
    zhi, zlo = unsafe_inv_dd_dd_(yhi, ylo)
    isfinite(zhi) || return DoubleFloat{T}(unsafe_inv_dd_dd(yhi, ylo)...)
    return DoubleFloat{T}(zhi, zlo)
end

@inline function square_db_db(x::DoubleFloat{T}) where {T<:IEEEFloat}
    isnotfinite(x) && return DoubleFloat{T}(square_dd_dd((x.hi, x.lo))...)
    zhi, zlo = square_dd_dd_((x.hi, x.lo))
    isfinite(zhi) || return DoubleFloat{T}(square_dd_dd((x.hi, x.lo))...)
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
