function asinh(x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
    result = abs(x)
    result = result + sqrt(square(result) + 1.0)
    result = log(result)
    return copysign(result, x)
end

function acosh(x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
    x < 1.0 && throw(DomainError("$x"))
    !isfinite(x) && return nan(typeof(x))
    result = x + sqrt(square(x) - 1.0)
    result = log(result)
    return result
end

function atanh(x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
    abs(x) > 1.0 && throw(DomainError("$x"))
    !isfinite(x) && return nan(typeof(x))
    twox = Double{T,E}(x.hi+x.hi, x.lo+x.lo)
    result = 1.0 + twox / (1.0 - x)
    result = log(result)
    result = Double(E, result.hi*0.5, result.lo*0.5)
    return result
end

function acsch(x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
    iszero(x) && throw(DomainError("$x"))
    !isfinite(x) && return nan(typeof(x))
    result = inv(x)
    result = sinh(result)
    return result
end

function asech(x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
    iszero(x) && return inf(Double{T,E})
    isone(x) && return zero(Double{T,E})
    !isfinite(x) && return nan(typeof(x))
    (x < 0.0 || x > 1.0) && throw(DomainError("$x"))
    result = inv(x)
    result = cosh(result)
    return result
end

function acoth(x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
    isone(x) && return inf(Double{T,E})
    isone(-x) && return -inf(Double{T,E})
    (-1.0 < x < 1.0) && throw(DomainError("$x"))
    !isfinite(x) && return nan(typeof(x))
    result = inv(x)
    result = tanh(result)
    return result
end
