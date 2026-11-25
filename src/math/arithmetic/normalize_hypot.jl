function hypot(x::DoubleFloat{T}, y::DoubleFloat{T}) where {T<:IEEEFloat}
    ax = abs(x)
    ay = abs(y)
    ay, ax = minmax(ax, ay)

    r = ay
    if !iszero(ax)
        r /= ax
    end
    r *= r

    rr = ax * sqrt(one(DoubleFloat{T}) + r)

    # from Base
    # use type of rr to make sure that return type
    #    is the same for all branches
    if isnan(ay)
        isinf(ax) && return oftype(rr, Inf)
        isinf(ay) && return oftype(rr, Inf)
        return oftype(rr, r)
    end
    return rr
 end

"""
    normalize(x,y)

    x_normalized^2 + y_normalized^2 == one(promote_type(typeof(x),typeof(y)))
"""
function normalize(x::DoubleFloat{T}, y::DoubleFloat{T}) where {T<:IEEEFloat}
    hypotenuse = hypot(x, y)
    if !iszero(hypotenuse) && isfinite(hypotenuse)
        xnorm = x / hypotenuse
        ynorm = y / hypotenuse
    else
        # try for xnorm, ynorm such that xnorm + ynorm == 1
        xnorm = x/(x+y)
        ynorm = y/(x+y)
    end
    return xnorm, ynorm
end

@inline _batch_hypot_range(x, y) =
    _batch_abs_bounded(x, 0.25, 8.0) & _batch_abs_bounded(y, 0.25, 8.0)

@inline _batch_positive_hypot_range(x, y) =
    _batch_bounded(x, 0.25, 8.0) & _batch_bounded(y, 0.25, 8.0)

@inline function _batch_positive_hypot(ax, ay)
    # Within this finite nonzero window both absolute heads are positive.
    # Base's min and max both select the second operand on a tie.
    small = ifelse(_batch_positive_less(ax, ay), ax, ay)
    large = ifelse(_batch_positive_less(ay, ax), ax, ay)
    r = _batch_div(small, large)
    r = _batch_mul(r, r)
    return _batch_mul(large, _batch_sqrt(_batch_add(one(Double64), r)))
end

@inline _batch_hypot(x, y) = _batch_positive_hypot(_batch_abs(x), _batch_abs(y))

@inline function _batch_normalize(x, y, magnitude::F) where {F}
    h = magnitude(x, y)
    return _batch_div(x, h), _batch_div(y, h)
end

_batch_kernel(::typeof(hypot), ::Type{Double64}, ::Type{Double64}, ::Type{Double64}) =
    _BatchAlternatives(_BatchKernel(_batch_positive_hypot_range, _batch_positive_hypot),
                       _BatchKernel(_batch_hypot_range, _batch_hypot))

_batch_kernel(::typeof(normalize), ::Type{Tuple{Double64,Double64}}, ::Type{Double64}, ::Type{Double64}) =
    _BatchAlternatives(_BatchKernel(_batch_positive_hypot_range,
                                   (x, y) -> _batch_normalize(x, y, _batch_positive_hypot)),
                       _BatchKernel(_batch_hypot_range,
                                   (x, y) -> _batch_normalize(x, y, _batch_hypot)))
