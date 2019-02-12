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
