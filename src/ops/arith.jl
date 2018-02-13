import Base: (+), (-), (*), (/), inv, sqrt 

@inline function add_dd_fl(xhi::T, xlo::T, y::T) where T<:IEEEFloat
    hi, lo = add_(xhi, y)
    c = lo + xlo
    hi, lo = add_hilo_(hi, c)
    return hi, lo
end

# Algorithm 6 from Tight and rigourous error bounds. relative error < 3u²
@inline function add_dd_dd(xhi::T, xlo::T, yhi::T, ylo::T) where T<:IEEEFloat
    hi, lo = add_(xhi, yhi)
    thi, tlo = add_(xlo, ylo)
    c = lo + thi
    hi, lo = add_hilo_(hi, c)
    c = tlo + lo
    hi, lo = add_hilo_(hi, c)
    return hi, lo
end

# Algorithm 6 from Tight and rigourous error bounds. relative error < 3u²
# reworked for subtraction
@inline function sub_dd_dd(xhi::T, xlo::T, yhi::T, ylo::T) where T<:IEEEFloat
    hi, lo = sub_(xhi, yhi)
    thi, tlo = sub_(xlo, ylo)
    c = lo + thi# Algorithm 9 from Tight and rigourous error bounds. relative error <= 2u²
    hi, lo = add_hilo_(hi, c)
    c = tlo + lo
    hi, lo = add_hilo_(hi, c)
    return hi, lo
end

# Algorithm 9 from Tight and rigourous error bounds. relative error <= 2u²
@inline function mul_dd_fl(xhi::T, xlo::T, y::T) where T<:IEEEFloat
    hi, lo = mul_(xhi, y)
    t = lo + xlo*y
    hi, lo = add_hilo_(hi, t)
    return hi, lo
end

# Algorithm 12 from Tight and rigourous error bounds.  relative error <= 5u²
@inline function mul_dd_dd(xhi::T, xlo::T, yhi::T, ylo::T) where T<:IEEEFloat
    hi, lo = mul_(xhi, yhi)
    t = xlo * ylo
    t = fma(xhi, ylo, t)
    t = fma(xlo, yhi, t)
    t = lo + t
    hi, lo = add_hilo_(hi, t)
    return hi, lo
end


@inline (+)(a::Double{F1,E}, b::Double{F2,E}) where {E<:Emphasis, F1<:IEEEFloat, F2<:IEEEFloat} =
    (+)(E, promote(a, b)...)

@inline (-)(a::Double{F1,E}, b::Double{F2,E}) where {E<:Emphasis, F1<:IEEEFloat, F2<:IEEEFloat} =
    (-)(E, promote(a, b)...)

@inline (*)(a::Double{F1,E}, b::Double{F2,E}) where {E<:Emphasis, F1<:IEEEFloat, F2<:IEEEFloat} =
    (*)(E, promote(a, b)...)

@inline (/)(a::Double{F1,E}, b::Double{F2,E}) where {E<:Emphasis, F1<:IEEEFloat, F2<:IEEEFloat} =
    (/)(E, promote(a, b)...)

# Algorithm 6 from Tight and rigourous error bounds. relative error < 3u²
function (+)(x::Double{T, E}, y::Double{T,E}) where {T<:IEEEFloat, E<:Emphasis}
    hi, lo = add_dd_dd(x.hi, x.lo, y.hi, y.lo)
    return Double{T, E}(hi, lo)
end

# Algorithm 6 from Tight and rigourous error bounds. relative error < 3u²
# reworked for subraction
function (-)(x::Double{T, E}, y::Double{T,E}) where {T<:IEEEFloat, E<:Emphasis}
    hi, lo = sub_dd_dd(x.hi, x.lo, y.hi, y.lo)
    return Double{T, E}(hi, lo)
end

# Algorithm 12 from Tight and rigourous error bounds for basic building blocks 
function (*)(x::Double{T,E}, y::Double{T,E}) where {T<:IEEEFloat,E<:Emphasis}
    hi, lo = mul_dd_dd(x.hi, x.lo, y.hi, y.lo)
    return Double{T, E}(hi, lo)    
end

function sqr(x::Double{T,E}) where {T<:IEEEFloat,E<:Emphasis}
    hi, lo = mul_(x.hi, x.hi)
    t = x.lo * x.lo
    t = fma(x.hi, x.lo, t)
    t = fma(x.lo, x.hi, t)
    t = lo + t
    hi, lo = add_hilo_(hi, t)
    return Double{T,E}(hi, lo)
end


function (/)(a::Double{T,Performance}, b::Double{T,Performance}) where {T<:IEEEFloat}
    hi1 = a.hi / b.hi
    hi, lo = mul_dd_fl(b.hi, b.lo, hi1)
    xhi, xlo = add_(a.hi, -hi)
    xlo -= lo
    xlo += a.lo
    hi2 = (xhi + xlo) / b.hi
    hi, lo = add_(hi1, hi2)
    return Double{T,Performance}(hi, lo)
end

#=
# Algorithm 18 from Tight and rigourous error bounds for basic building blocks 
function (/)(x::Double{T,Accuracy}, y::Double{T,Accuracy}) where {T<:IEEEFloat}
    hi = inv(y.hi)
    rhi = fma(-y.hi, hi, one(T))
    rlo = y.lo * hi
    rhi, rlo = add_hilo_hilo(rhi, rlo)
    rhi, rlo = prod_dd_fl(rhi, rlo, hi)
    rhi, rlo = add_dd_fl(rhi, rlo, hi)
    hi, lo = prod__dd_dd(x.hi, x.lo, rhi, rlo)
    return Double(hi, lo)
end
=#

function (/)(a::Double{T,Accuracy}, b::Double{T,Accuracy}) where {T<:IEEEFloat}
    q1 = a.hi / b.hi
    th,tl = mul_dd_fl(b.hi,b.lo,q1)
    rh,rl = add_dd_dd(a.hi, a.lo, -th,-tl)
    q2 = rh / b.hi
    th,tl = mul_dd_fl(b.hi,b.lo,q2)
    rh,rl = add_dd_dd(rh, rl, -th,-tl)
    q3 = rh / b.hi
    q1, q2 = add_hilo_(q1, q2)
    rh,rl = add_dd_fl(q1, q2, q3)
    return Double{T,Accuracy}(rh, rl)
end

@inline inv(x::Double{T, E}) where {T<:IEEEFloat, E<:Emphasis} = one(T)/x

function sqrt(x::Double{T, E}) where {T<:IEEEFloat, E<:Emphasis}
    approxsqrt = sqrt(x.hi)
    approx = x/approxsqrt
    approx = approx + approxsqrt
    return Double{T,E}(0.5*approx.hi, 0.5*approx.lo)
end

