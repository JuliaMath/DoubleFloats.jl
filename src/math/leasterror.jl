@inline function two_inv(b::T) where {T<:FloatWithFMA}
     hi = inv(b)
     lo = fma(-hi, b, one(T))
     lo /= b
     return hi, lo
end

@inline function two_dvi(a::T, b::T) where {T<:FloatWithFMA}
     hi = a / b
     lo = fma(-hi, b, a)
     lo /= b
     return hi, lo
end

@inline function two_sqrt(a::T) where {T<:FloatWithFMA}
    hi = sqrt(a)
    lo = fma(-hi, hi, a)
    lo /= 2
    lo /= hi
    return hi, lo
end
