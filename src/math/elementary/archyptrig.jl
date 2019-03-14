function asinh(x::DoubleFloat{T}) where {T<:IEEEFloat}
    isnan(x) && return x
    isinf(x) && return x
    signbit(x) && return - asinh(-x)
    result = abs(x)
    result = result + sqrt(square(result) + 1.0)
    result = log(result)
    return copysign(result, x)
end

function acosh(x::DoubleFloat{T}) where {T<:IEEEFloat}
    isnan(x) && return x
    isinf(x) && !signbit(x) && return x
    (x < 1.0 || isinf(x)) && throw(DomainError("$x"))
    result = x + sqrt(square(x) - 1.0)
    result = log(result)
    return result
end

function atanh(x::DoubleFloat{T}) where {T<:IEEEFloat}
    isnan(x) && return x
    (abs(x) > 1.0 || isinf(x)) && throw(DomainError("$x"))
    twox = DoubleFloat{T}(x.hi+x.hi, x.lo+x.lo)
    result = 1.0 + twox / (1.0 - x)
    result = log(result)
    result = DoubleFloat{T}(result.hi*0.5, result.lo*0.5)
    return result
end

function acsch(x::DoubleFloat{T}) where {T<:IEEEFloat}
    isnan(x) && return x
    isinf(x) && return zero(DoubleFloat{T})
    iszero(x) && return signbit(x) ? -DoubleFloat{T}(Inf) : DoubleFloat{T}(Inf)
    invx = inv(x)
    invx2 = inv(x*x)
    result = log(sqrt(1 + invx2) + invx)
    return result
end

function asech(x::DoubleFloat{T}) where {T<:IEEEFloat}
    isnan(x) && return x
    (x < 0.0 || x > 1.0 || isinf(x)) && throw(DomainError("$x"))
    iszero(x) && return inf(DoubleFloat{T})
    isone(x) && return zero(DoubleFloat{T})
    invx = inv(x)
    result = fma(sqrt(invx + 1), sqrt(invx - 1), invx)
    return log(result)
end

function acoth(x::DoubleFloat{T}) where {T<:IEEEFloat}
    isnan(x) && return x
    isinf(x) && return copysign(zero(DoubleFloat{T}), x)
    isone(x) && return inf(DoubleFloat{T})
    isone(-x) && return -inf(DoubleFloat{T})
    (-1.0 < x < 1.0) && throw(DomainError("$x"))
    invx = inv(x)
    result = (log(1+invx) - log(1-invx))/2
    return result
end
