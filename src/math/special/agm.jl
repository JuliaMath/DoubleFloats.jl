function agm(x::T, y::T) where {T<:Real}
    a, b = x, y
    epsilon = eps(min(a,b))

    signbit(a) != signbit(b) && throw(DomainError("$a * $b must be nonnegative"))

    while abs(a-b) > epsilon
     c = (a + b) * 0.5
     b = sqrt(a * b)
     a = c
    end

    return a
end

agm1(x::T) where {T<:Real} = agm(one(T), x)
