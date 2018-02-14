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


# Algorithm 6 from Tight and rigourous error bounds. relative error < 3u²
function (+)(x::Double{T, E}, y::Double{T,E}) where {T<:IEEEFloat, E<:Emphasis}
    hi, lo = add_dd_dd(HI(x), LO(x), HI(y), LO(y))
    return Double{T, E}(hi, lo)
end

# Algorithm 6 from Tight and rigourous error bounds. relative error < 3u²
# reworked for subraction
function (-)(x::Double{T, E}, y::Double{T,E}) where {T<:IEEEFloat, E<:Emphasis}
    hi, lo = sub_dd_dd(HI(x), LO(x), HI(y), LO(y))
    return Double{T, E}(hi, lo)
end

# Algorithm 12 from Tight and rigourous error bounds for basic building blocks
function (*)(x::Double{T,E}, y::Double{T,E}) where {T<:IEEEFloat,E<:Emphasis}
    hi, lo = mul_dd_dd(HI(x), LO(x), HI(y), LO(y))
    return Double{T, E}(hi, lo)
end

function sqr(x::Double{T,E}) where {T<:IEEEFloat,E<:Emphasis}
    hi, lo = mul_(HI(x), HI(x))
    t = LO(x) * LO(x)
    t = fma(HI(x), LO(x), t)
    t = fma(LO(x), HI(x), t)
    t = lo + t
    hi, lo = add_hilo_(hi, t)
    return Double{T,E}(hi, lo)
end


function (/)(a::Double{T,Performance}, b::Double{T,Performance}) where {T<:IEEEFloat}
    hi1 = HI(a) / HI(b)
    hi, lo = mul_dd_fl(HI(b), LO(b), hi1)
    xhi, xlo = add_(HI(a), -hi)
    xlo -= lo
    xlo += LO(a)
    hi2 = (xhi + xlo) / HI(b)
    hi, lo = add_(hi1, hi2)
    return Double{T,Performance}(hi, lo)
end

function (/)(a::Double{T,Accuracy}, b::Double{T,Accuracy}) where {T<:AbstractFloat}
    hi = inv(HI(b))
    rhi = fma(-HI(b), hi, one(T))
    rlo = LO(b) * hi
    rhi, rlo = add_hilo_(rhi, rlo)
    rhi, rlo = mul_dd_fl(rhi, rlo, hi)
    rhi, rlo = add_dd_fl(rhi, rlo, hi)
    hi, lo = mul_dd_dd(HI(a), LO(a), rhi, rlo)
    return Double(hi, lo)
end

#=
# Algorithm 18 from Tight and rigourous error bounds for basic building blocks
function (/)(x::Double{T,Accuracy}, y::Double{T,Accuracy}) where {T<:IEEEFloat}
    hi = inv(HI(y))
    rhi = fma(-HI(y), hi, one(T))
    rlo = LO(y) * hi
    rhi, rlo = add_hilo_(rhi, rlo)
    rhi, rlo = mul_dd_fl(rhi, rlo, hi)
    rhi, rlo = add_dd_fl(rhi, rlo, hi)
    hi, lo = mul__dd_dd(HI(x), LO(x), rhi, rlo)
    return Double(hi, lo)
end
=#
function (div_dd_fl)(x::Double{T,E}, y::T) where {T<:AbstractFloat, E<:Emphasis}
    hi = inv(HI(y))
    rhi = fma(-HI(y), hi, one(T))
    rhi, rlo = mul_(rhi, hi)
    rhi, rlo = add_dd_fl(rhi, rlo, hi)
    rhi, rlo = mul_dd_dd(HI(x), LO(x), rhi, rlo)
    return rhi, rlo
 end

@inline inv(x::Double{T, E}) where {T<:IEEEFloat, E<:Emphasis} = one(Double{T,E})/x

function sqrt(x::Double{T, E}) where {T<:IEEEFloat, E<:Emphasis}
    is_zero(x) && return x
    signbit(x) && throw(DomainError("sqrt(x) expects x >= 0"))

    half = T(0.5)
    dhalf = Double{T,E}(half)

    r = inv(sqrt(HI(x)))
    h = Double{T,E}(HI(x) * half, LO(x) * half)

    r2 = r * r
    hr2 = h * r2
    radj = dhalf - hr2
    radj = radj * r
    r = r + radj

    r2 = r * r
    hr2 = h * r2
    radj = dhalf - hr2
    radj = radj * r
    r = r + radj

    r = r * x

    return r
end

