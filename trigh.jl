function sinh(x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
    x < 0 && return -sinh(-x)
    iszero(x) && return zero(x)
    !isfinite(x) && return nan(typeof(x))

    y = exp(x) - exp(-x)
    z = Double(E, y.hi*0.5, y.lo*0.5)
    return z
end

function cosh(x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
    x < 0 && return cosh(-x)
    iszero(x) && return zero(x)
    !isfinite(x) && return nan(typeof(x))

    y = exp(x) + exp(-x)
    z = Double(E, y.hi*0.5, y.lo*0.5)
    return z
end

function tanh(x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
    x < 0 && return -tanh(-x)
    iszero(x) && return zero(x)
    !isfinite(x) && return nan(typeof(x))
    epos = exp(x)
    eneg = exp(-x)
    z = (epos - eneg) / (epos + eneg)
    return z
end

csch(x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis} =
    inv(sinh(x))

sech(x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis} =
    inv(cosh(x))

coth(x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis} =
    inv(tanh(x))
