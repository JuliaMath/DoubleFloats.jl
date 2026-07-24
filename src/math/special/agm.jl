function agm(x::T, y::T) where {T<:Real}
    signbit(x) != signbit(y) && throw(DomainError("$x * $y must be nonnegative"))
    (iszero(x) || iszero(y)) && return zero(T)

    a, b = x, y
    d = abs(a - b)
    while true
        c = (a + b) * 0.5
        b = sqrt(a * b)
        a = c
        dnew = abs(a - b)
        # a NaN gap means an intermediate overflowed; propagate it
        isnan(dnew) && return a + b
        # quadratic convergence ends at the roundoff floor, where the gap
        # stops shrinking; a fixed tolerance taken from the initial operands
        # can lie below that floor and stall the loop forever
        (iszero(dnew) || dnew >= d) && break
        d = dnew
    end

    return a
end

agm1(x::T) where {T<:Real} = agm(one(T), x)
