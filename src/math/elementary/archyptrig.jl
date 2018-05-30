#=
function asinh(x::DoubleFloat{T}) where {T<:AbstractFloat}
    signbit(x) && return -asinh(abs(x))
    
    result = x + sqrt(square(x) + 1.0)
    result = log(result)
    return result
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
    
    if abs(x.hi) == one(T)
        if x.hi > 0
            z = posinf(typeof(x))
        else
            z = neginf(typeof(x))
        end
    else
        oneplus  = 1.0 + x
        oneminus = 1.0 - x
        z = oneplus / oneminus
        z = log(z)
        z = DoubleFloat{T}(z.hi/2, z.lo/2)
    end
    
    return z
end

function acsch(x::DoubleFloat{T}) where {T<:AbstractFloat}
    iszero(x) && throw(DomainError("$x"))
    !isfinite(x) && return nan(typeof(x))
    result = inv(x)
    result = sinh(result)
    return result
end

function asech(x::DoubleFloat{T}) where {T<:AbstractFloat}
    iszero(x) && return inf(DoubleFloat{T})
    isone(x) && return zero(DoubleFloat{T})
    !isfinite(x) && return nan(typeof(x))
    (x < 0.0 || x > 1.0) && throw(DomainError("$x"))
    result = inv(x)
    result = cosh(result)
    return result
end

function acoth(x::DoubleFloat{T}) where {T<:AbstractFloat}
    isone(x) && return inf(DoubleFloat{T})
    isone(-x) && return -inf(DoubleFloat{T})
    (-1.0 < x < 1.0) && throw(DomainError("$x"))
    !isfinite(x) && return nan(typeof(x))
    result = inv(x)
    result = tanh(result)
    return result
end
=#
