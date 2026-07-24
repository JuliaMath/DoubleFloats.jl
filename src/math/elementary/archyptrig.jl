function asinh(x::DoubleFloat{T}) where {T<:IEEEFloat}
    isnan(x) && return x
    isinf(x) && return x
    ax = abs(x)
    if HI(ax) >= 4.0 / eps(T)
        # sqrt(x^2 + 1) == x to double-double precision here, and
        # square(ax) would overflow long before ax does
        result = log(ax) + logtwo(DoubleFloat{T})
    else
        # all terms of u are nonnegative, so u carries full relative
        # precision into log1p; the direct log(x + sqrt(x^2 + 1)) loses
        # small x to the absolute floor of the addition of 1
        x2 = square(ax)
        u = ax + x2 / (1.0 + sqrt(1.0 + x2))
        result = log1p(u)
    end
    return copysign(result, x)
end

function acosh(x::DoubleFloat{T}) where {T<:IEEEFloat}
    isnan(x) && return x
    isinf(x) && !signbit(x) && return x
    (x < 1.0 || isinf(x)) && throw(DomainError("$x"))
    if HI(x) >= 4.0 / eps(T)
        # sqrt(x^2 - 1) == x to double-double precision here, and
        # square(x) would overflow long before x does
        return log(x) + logtwo(DoubleFloat{T})
    end
    # u = x - 1 is exact and u*(2 + u) has no cancellation, keeping full
    # relative precision as x -> 1, where square(x) - 1 loses it
    u = x - 1.0
    return log1p(u + sqrt(u * (2.0 + u)))
end

function atanh(x::DoubleFloat{T}) where {T<:IEEEFloat}
    isnan(x) && return x
    (abs(x) > 1.0 || isinf(x)) && throw(DomainError("$x"))
    ax = abs(x)
    if HI(ax) <= 0.5
        # 2x/(1 - x) carries full relative precision into log1p as x -> 0
        result = mul_by_half(log1p(mul_by_two(ax) / (1.0 - ax)))
    else
        # the terms have opposite signs, so their difference has no
        # cancellation; each is accurate however close ax is to 1
        result = mul_by_half(log1p(ax) - log1p(-ax))
    end
    return copysign(result, x)
end

function acsch(x::DoubleFloat{T}) where {T<:IEEEFloat}
    return asinh(inv(x))
end

function asech(x::DoubleFloat{T}) where {T<:IEEEFloat}
    isnan(x) && return x
    (x < 0.0 || x > 1.0) && throw(DomainError("$x"))
    iszero(HI(x)) && return inf(DoubleFloat{T})
    # v = 1/x - 1 formed with an exact numerator, keeping full relative
    # precision as x -> 1 (acosh(inv(x)) loses it in the inversion)
    v = (1.0 - x) / x
    if HI(v) >= 4.0 / eps(T)
        return log(v) + logtwo(DoubleFloat{T})
    end
    return log1p(v + sqrt(v * (2.0 + v)))
end

function acoth(x::DoubleFloat{T}) where {T<:IEEEFloat}
    isnan(x) && return x
    (-1.0 < x < 1.0) && throw(DomainError("$x"))
    ax = abs(x)
    # 1 + 2/(x - 1) == (x + 1)/(x - 1); x - 1 is exact, so full relative
    # precision is kept both as x -> 1 and as x -> Inf
    result = mul_by_half(log1p(2.0 / (ax - 1.0)))
    return copysign(result, x)
end
