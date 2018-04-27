function hypot(x::Double{T,E}, y::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
    ax = abs(x)
    ay = abs(y)
    ay, ax = minmax(ax, ay)

    r = ay
    if !iszero(ax)
        r /= ax
    end
    r *= r

    rr = ax * sqrt(one(Double{T,E}) + r)

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
function normalize(x::Double{T,E}, y::Double{T,E}) where
                  {T<:AbstractFloat, E<:Emphasis}
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

function muladd(x::Double{T,E}, y::Double{T,E}, z::Double{T,E}) where
                  {T<:AbstractFloat, E<:Accuracy}
    xy = mul223(HILO(x), HILO(y))
    xyz = add322(xy, HILO(z))
    return Double(E, xyz)
end

function fma(x::Double{T,E}, y::Double{T,E}, z::Double{T,E}) where
                  {T<:AbstractFloat, E<:Accuracy}
    xy = mul223(HILO(x), HILO(y))
    xyz = add322(xy, HILO(z))
    return Double(E, xyz)
end
