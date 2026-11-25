function Base.div(x::DoubleFloat{T}, y::DoubleFloat{T}) where {T<:IEEEFloat}
    (!isfinite(x) || isnan(y)) && return nan(DoubleFloat{T})
    !isfinite(y) && return zero(DoubleFloat{T})
    return trunc(x / y)
end

function Base.fld(x::DoubleFloat{T}, y::DoubleFloat{T}) where {T<:IEEEFloat}
    (!isfinite(x) || isnan(y)) && return nan(DoubleFloat{T})
    !isfinite(y) && return zero(DoubleFloat{T})
    return floor(x / y)
end

function Base.cld(x::DoubleFloat{T}, y::DoubleFloat{T}) where {T<:IEEEFloat}
    (!isfinite(x) || isnan(y)) && return nan(DoubleFloat{T})
    !isfinite(y) && return zero(DoubleFloat{T})
    return ceil(x / y)
end

function Base.rem(x::DoubleFloat{T}, y::DoubleFloat{T}) where {T<:IEEEFloat}
    (!isfinite(x) || isnan(y)) && return nan(DoubleFloat{T})
    !isfinite(y) && return x
    return x - div(x, y) * y
end

function Base.mod(x::DoubleFloat{T}, y::DoubleFloat{T}) where {T<:IEEEFloat}
    (!isfinite(x) || isnan(y)) && return nan(DoubleFloat{T})
    !isfinite(y) && return x
    return x - fld(x, y) * y
end

function Base.divrem(x::DoubleFloat{T}, y::DoubleFloat{T}) where {T<:IEEEFloat}
    (!isfinite(x) || isnan(y)) && return nan(DoubleFloat{T})
    !isfinite(y) && return zero(DoubleFloat{T})
    dv = trunc(x / y)
    rm = x - dv * y
    return dv, rm
end

function Base.fldmod(x::DoubleFloat{T}, y::DoubleFloat{T}) where {T<:IEEEFloat}
    (!isfinite(x) || isnan(y)) && return nan(DoubleFloat{T})
    !isfinite(y) && return zero(DoubleFloat{T})
    fr = floor(x / y)
    md = x - fr * y
    return fr, md
end
