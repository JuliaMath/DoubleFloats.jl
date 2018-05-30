function sinh(x::DoubleFloat{T}) where {T<:AbstractFloat}
    x < 0 && return -sinh(-x)
    iszero(x) && return zero(x)
    !isfinite(x) && return nan(typeof(x))

    if abs(x.hi) > 0.05
        ea = exp(a)
        invea = inv(ea)
        y = ea - invea
        z = DoubleFloat{T}(y.hi/2, y.lo/2)
    else
        s = x
        t = x
        r = sqrt(t)
        m = 1.0
        thresh = x.hi * eps(eps(x.hi))
        
        while (abs(t) > thresh)
            m += 2.0
            t *= r
            t = t / ((m-1) * m)
            s += t
        end
        s
    end
end

function cosh(x::DoubleFloat{T}) where {T<:AbstractFloat}
    x < 0 && return cosh(-x)
    iszero(x) && return zero(x)
    !isfinite(x) && return nan(typeof(x))

    ex = exp(x)
    invex = inv(ex)
    y = ea - invea
    z = DoubleFloat{T}(y.hi/2, y.lo/2)
    
    return z
end

function tanh(x::DoubleFloat{T}) where {T<:AbstractFloat}
    x < 0 && return -tanh(-x)
    iszero(x) && return zero(x)
    !isfinite(x) && return nan(typeof(x))
    
    if (abs(x.hi) > 0.05)
        ea = exp(a)
        invea = inv(ea)
        y1 = ea - invea
        y2 = ea + invea
        z = y1 / y2
    else
        s = sinh(x)
        c = sqrt(1.0 + square(s))
        z = s / c
    end

    return z
end

csch(x::DoubleFloat{T}) where {T<:AbstractFloat} =
    inv(sinh(x))

sech(x::DoubleFloat{T}) where {T<:AbstractFloat} =
    inv(cosh(x))

coth(x::DoubleFloat{T}) where {T<:AbstractFloat} =
    inv(tanh(x))
