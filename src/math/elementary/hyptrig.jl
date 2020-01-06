const fp64max = floatmax(Float64)
const maxhyp_fp64max = 710.4758600739439
const minhyp_fp64max = 5.562684646268003e-309

function sinh(x::DoubleFloat{T}) where {T<:IEEEFloat}
    abs(HI(x)) > maxhyp_fp64max && return DoubleFloat{T}(copysign(Inf, HI(x)))
    !isfinite(HI(x)) && return x
    iszero(x) && return zero(x)
    signbit(x) && return -sinh(-x)
    
    y = exp(x) - exp(-x)
    z = DoubleFloat{T}(y.hi*0.5, y.lo*0.5)
    return z
end

function cosh(x::DoubleFloat{T}) where {T<:IEEEFloat}
    abs(HI(x)) > maxhyp_fp64max && return DoubleFloat{T}(Inf)
    !isfinite(x) && return abs(x)
    iszero(x) && return one(x)
    signbit(x) && return cosh(-x)

    y = exp(x) + exp(-x)
    z = DoubleFloat{T}(y.hi*0.5, y.lo*0.5)
    return z
end

function tanh(x::DoubleFloat{T}) where {T<:IEEEFloat}
    abs(HI(x)) > maxhyp_fp64max && return copysign(one(DoubleFloat{T}), x)
    return sinh(x) / cosh(x)
end
#=
function tanh(x::DoubleFloat{T}) where {T<:IEEEFloat}
    x < 0 && return -tanh(-x)
    iszero(x) && return zero(x)
    !isfinite(x) && return nan(typeof(x))
    epos = exp(x)
    eneg = exp(-x)
    z = (epos - eneg) / (epos + eneg)
    return z
end
=#

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
