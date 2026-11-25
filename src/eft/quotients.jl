@inline function two_inv(b::T) where {T<:FloatWithFMA}
    hi = inv(b)
    if !isfinite(hi) || iszero(hi)
        return zero_error_result(hi)
    end
    lo = fma(-hi, b, one(T))
    lo /= b
    return hi, lo
end

@inline function two_dvi(a::T, b::T) where {T<:FloatWithFMA}
    hi = a / b
    if !isfinite(hi) || iszero(hi)
        return zero_error_result(hi)
    end
    lo = fma(-hi, b, a)
    lo /= b
    return hi, lo
end

@inline function two_sqrt(a::T) where {T<:FloatWithFMA}
    hi = sqrt(a)
    if !isfinite(hi) || iszero(hi)
        return zero_error_result(hi)
    end
    lo = fma(-hi, hi, a) / (hi + hi)
    return hi, lo
end
