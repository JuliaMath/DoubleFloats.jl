function asinh(x::DoubleFloat{T}) where {T<:AbstractFloat}
    result = abs(x)
    result = result + sqrt(square(result) + 1.0)
    result = log(result)
    return copysign(result, x)
end

function acosh(x::DoubleFloat{T}) where {T<:AbstractFloat}
    x < 1.0 && throw(DomainError("$x"))
    !isfinite(x) && return nan(typeof(x))
    result = x + sqrt(square(x) - 1.0)
    result = log(result)
    return result
end

function atanh(x::DoubleFloat{T}) where {T<:AbstractFloat}
    abs(x) > 1.0 && throw(DomainError("$x"))
    !isfinite(x) && return nan(typeof(x))
    twox = DoubleFloat{T}(x.hi+x.hi, x.lo+x.lo)
    result = 1.0 + twox / (1.0 - x)
    result = log(result)
    result = DoubleFloat{T}(result.hi*0.5, result.lo*0.5)
    return result
end

function acsch(x::DoubleFloat{T}) where {T<:AbstractFloat}
    isinf(x) && return zero(DoubleFloat{T})
    isnan(x) && return nan(typeof(x))
    iszero(x) && return signbit(x) ? -DoubleFloat{T}(Inf) : DoubleFloat{T}(Inf)
    invx = inv(x)
    invx2 = inv(x*x)
    result = log(sqrt(1 + invx2) + invx)
    return result
end

function asech(x::DoubleFloat{T}) where {T<:AbstractFloat}
    iszero(x) && return inf(DoubleFloat{T})
    isone(x) && return zero(DoubleFloat{T})
    !isfinite(x) && return nan(typeof(x))
    (x < 0.0 || x > 1.0) && throw(DomainError("$x"))
    invx = inv(x)
    result = fma(sqrt(invx + 1), sqrt(invx - 1), invx)
    return log(result)
end

function acoth(x::DoubleFloat{T}) where {T<:AbstractFloat}
    isone(x) && return inf(DoubleFloat{T})
    isone(-x) && return -inf(DoubleFloat{T})
    (-1.0 < x < 1.0) && throw(DomainError("$x"))
    !isfinite(x) && return nan(typeof(x))
    invx = inv(x)
    result = (log(1+invx) - log(1-invx))/2
    return result
end
