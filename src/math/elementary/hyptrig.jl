const fp64max = floatmax(Float64)
const maxhyp_fp64max = 710.4758600739439
const minhyp_fp64max = 5.562684646268003e-309

function sinh(x::DoubleFloat{T}) where {T<:IEEEFloat}
    abs(HI(x)) > maxhyp_fp64max && return DoubleFloat{T}(copysign(Inf, HI(x)))
    !isfinite(HI(x)) && return x
    iszero(x) && return zero(x)
    signbit(x) && return -sinh(-x)

    if HI(x) >= 709.0
        # exp(x) overflows above ln(floatmax) ~ 709.7827, yet sinh(x) stays
        # representable up to ~710.4758; exp(-x) is negligible here, so
        # sinh(x) == exp(x)/2, computed via Float128 to span the gap
        return DoubleFloat{T}(exp(Float128(x)) * 0.5)
    elseif HI(x) <= 1.0
        # expm1 keeps full relative precision as x -> 0, where
        # exp(x) - exp(-x) loses it to cancellation
        u = expm1(x)
        return mul_by_half(u + u / (1.0 + u))
    elseif HI(x) >= 37.5
        # exp(-2x) < 2^-108: sinh(x) == exp(x)/2 at working precision
        return mul_by_half(exp(x))
    end

    w = exp(x)
    return mul_by_half(w - inv(w))
end

function cosh(x::DoubleFloat{T}) where {T<:IEEEFloat}
    abs(HI(x)) > maxhyp_fp64max && return DoubleFloat{T}(Inf)
    !isfinite(x) && return abs(x)
    iszero(x) && return one(x)
    signbit(x) && return cosh(-x)

    if HI(x) >= 709.0
        # see sinh: cosh(x) == exp(x)/2 at this magnitude
        return DoubleFloat{T}(exp(Float128(x)) * 0.5)
    elseif HI(x) >= 37.5
        return mul_by_half(exp(x))
    end

    w = exp(x)                     # w + 1/w has no cancellation anywhere
    return mul_by_half(w + inv(w))
end

function tanh(x::DoubleFloat{T}) where {T<:IEEEFloat}
    isnan(x) && return x
    ax = abs(x)
    if HI(ax) <= 0.5
        # u/(u+2) keeps full relative precision as x -> 0
        u = expm1(-mul_by_two(ax))          # u in (-0.64, 0]
        t = -u / (u + 2.0)
    else
        w = exp(-mul_by_two(ax))            # w in [0, 0.37): 1-w is safe
        t = (1.0 - w) / (1.0 + w)
    end
    return copysign(t, x)
end

function csch(x::DoubleFloat{T}) where {T<:IEEEFloat}
    abs(HI(x)) > maxhyp_fp64max && return copysign(zero(DoubleFloat{T}), x)
    return inv(sinh(x))
end

function sech(x::DoubleFloat{T}) where {T<:IEEEFloat}
    abs(HI(x)) > maxhyp_fp64max && return zero(DoubleFloat{T})    
    return inv(cosh(x))
end

function coth(x::DoubleFloat{T}) where {T<:IEEEFloat}
    abs(HI(x)) > maxhyp_fp64max && return copysign(one(DoubleFloat{T}), x)
    return cosh(x) / sinh(x)
end

# The formulas match the scalar positive branches. The shared pair also
# admits doubled arguments up to 10 in complex kernels, far below the
# sinh/cosh shortcut at 37.5. All reciprocals and denominators are finite.
@inline _batch_hyp_range(x) = _batch_bounded(x, 1.1, 5.0)
@inline function _batch_sinhcosh(x)
    w = _batch_exp(x)
    wi = _batch_inv(w)
    return mul_by_half(_batch_sub(w, wi)), mul_by_half(_batch_add(w, wi))
end
@inline _batch_sinh(x) = first(_batch_sinhcosh(x))
@inline _batch_cosh(x) = last(_batch_sinhcosh(x))
@inline function _batch_tanh(x)
    w = _batch_exp(_batch_neg(mul_by_two(x)))
    return _batch_div(_batch_sub(1.0, w), _batch_add(1.0, w))
end
@inline _batch_csch(x) = _batch_inv(_batch_sinh(x))
@inline _batch_sech(x) = _batch_inv(_batch_cosh(x))
@inline function _batch_coth(x)
    s, c = _batch_sinhcosh(x)
    return _batch_div(c, s)
end

for (scalar, kernel) in ((sinh, _batch_sinh), (cosh, _batch_cosh), (tanh, _batch_tanh),
        (csch, _batch_csch), (sech, _batch_sech), (coth, _batch_coth))
    @eval _batch_kernel(::typeof($scalar), ::Type{Double64}, ::Type{Double64}) =
        _BatchKernel(_batch_hyp_range, $kernel)
end
