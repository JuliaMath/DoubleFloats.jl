function sinh(x::DoubleFloat{T}) where {T<:AbstractFloat}
    x < 0 && return -sinh(-x)
    iszero(x) && return zero(x)
    !isfinite(x) && return nan(typeof(x))

    y = exp(x) - exp(-x)
    z = DoubleF64(y.hi*0.5, y.lo*0.5)
    return z
end

function cosh(x::DoubleFloat{T}) where {T<:AbstractFloat}
    x < 0 && return cosh(-x)
    iszero(x) && return zero(x)
    !isfinite(x) && return nan(typeof(x))

    y = exp(x) + exp(-x)
    z = DoubleFloat{T}(y.hi*0.5, y.lo*0.5)
    return z
end

function tanh(x::DoubleFloat{T}) where {T<:AbstractFloat}
    x < 0 && return -tanh(-x)
    iszero(x) && return zero(x)
    !isfinite(x) && return nan(typeof(x))
    epos = exp(x)
    eneg = exp(-x)
    z = (epos - eneg) / (epos + eneg)
    return z
end

csch(x::DoubleFloat{T}) where {T<:AbstractFloat} =
    inv(sinh(x))

sech(x::DoubleFloat{T}) where {T<:AbstractFloat} =
    inv(cosh(x))

coth(x::DoubleFloat{T}) where {T<:AbstractFloat} =
    inv(tanh(x))
