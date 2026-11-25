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

# In these positive windows each log1p argument has a positive head below
# 0.06. In the near-one formulas the differences and radicands stay
# positive even at the largest allowed low-limb correction.
@inline function _batch_asinh(x)
    x2 = _batch_square(x)
    return _log1p_near(_batch_add(x, _batch_div(x2, _batch_add(1.0, _batch_sqrt(_batch_add(1.0, x2))))))
end
@inline _batch_acsch(x) = _batch_asinh(_batch_inv(x))

@inline _batch_acosh_offset(u) = _log1p_near(_batch_add(u, _batch_sqrt(_batch_mul(u, _batch_add(2.0, u)))))
@inline _batch_acosh(x) = _batch_acosh_offset(_batch_sub(x, 1.0))
@inline _batch_asech(x) = _batch_acosh_offset(_batch_div(_batch_sub(1.0, x), x))
@inline _batch_atanh(x) = mul_by_half(_log1p_near(_batch_div(mul_by_two(x), _batch_sub(1.0, x))))
# The scalar expression uses a mixed-float reciprocal and multiplication.
@inline function _batch_acoth(x)
    y = _batch_inv(_batch_sub(x, 1.0))
    ratio = unsafe_double(Float64, _mul_fpdd_dd(two_prod_, two_sum4_, 2.0, HILO(y))...)
    return mul_by_half(_log1p_near(ratio))
end

for (scalar, kernel, lower, upper) in (
    (asinh, _batch_asinh, 0.005, 0.045),
    (acosh, _batch_acosh, 1.00002, 1.001),
    (atanh, _batch_atanh, 0.005, 0.025),
    (acsch, _batch_acsch, 30.0, 50.0),
    (asech, _batch_asech, 0.999, 0.99998),
    (acoth, _batch_acoth, 40.0, 100.0),
)
    @eval _batch_kernel(::typeof($scalar), ::Type{Double64}, ::Type{Double64}) =
        _BatchKernel(x -> _batch_bounded(x, $lower, $upper), $kernel)
end
