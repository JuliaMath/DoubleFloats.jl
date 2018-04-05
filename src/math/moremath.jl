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
