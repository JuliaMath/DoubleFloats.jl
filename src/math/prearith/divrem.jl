function div(x::DoubleFloat{T}, y::DoubleFloat{T}) where {T<:IEEEFloat}
    (!isfinite(x) || isnan(y)) && return nan(DoubleFloat{T})
    !isfinite(y) && return zero(DoubleFloat{T})
    return trunc(x / y)
end

function fld(x::DoubleFloat{T}, y::DoubleFloat{T}) where {T<:IEEEFloat}
    (!isfinite(x) || isnan(y)) && return nan(DoubleFloat{T})
    !isfinite(y) && return zero(DoubleFloat{T})
    return floor(x / y)
end

function cld(x::DoubleFloat{T}, y::DoubleFloat{T}) where {T<:IEEEFloat}
    (!isfinite(x) || isnan(y)) && return nan(DoubleFloat{T})
    !isfinite(y) && return zero(DoubleFloat{T})
    return ceil(x / y)
end

function rem(x::DoubleFloat{T}, y::DoubleFloat{T}) where {T<:IEEEFloat}
    (!isfinite(x) || isnan(y)) && return nan(DoubleFloat{T})
    !isfinite(y) && return x
    return x - div(x,y) * y
end

function mod(x::DoubleFloat{T}, y::DoubleFloat{T}) where {T<:IEEEFloat}
    (!isfinite(x) || isnan(y)) && return nan(DoubleFloat{T})
    !isfinite(y) && return x
    return x - fld(x,y) * y
end

function divrem(x::DoubleFloat{T}, y::DoubleFloat{T}) where {T<:IEEEFloat}
    (!isfinite(x) || isnan(y)) && return nan(DoubleFloat{T})
    !isfinite(y) && return zero(DoubleFloat{T})
    dv = trunc(x / y)
    rm = x - dv * y
    return dv, rm
end

function fldmod(x::DoubleFloat{T}, y::DoubleFloat{T}) where {T<:IEEEFloat}
    (!isfinite(x) || isnan(y)) && return nan(DoubleFloat{T})
    !isfinite(y) && return zero(DoubleFloat{T})
    fr = floor(x / y)
    md = x - fr * y
    return fr, md
end
