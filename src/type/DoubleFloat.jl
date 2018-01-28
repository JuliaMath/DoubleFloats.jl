abstract type AbstractDouble{T} <: MultipartFloat{T} end

struct Double{T, E<:Emphasis} <: AbstractDouble{T}
    hi::T
    lo::T
end

@inline hi(x::Double{T,E}) where {T,E<:Emphasis} = x.hi
@inline lo(x::Double{T,E}) where {T,E<:Emphasis} = x.lo

@inline hi(x::T) where {T<:AbstractFloat} = x
@inline lo(x::T) where {T<:AbstractFloat} = zero(T)

# initializers

Double() = Double{Float64, Accuracy}(zero(Float64), zero(Float64))
Double(::Type{Accuracy}) = Double{Float64, Accuracy}(zero(Float64), zero(Float64))
Double(::Type{Performance}) = Double{Float64, Performance}(zero(Float64), zero(Float64))
Double(::Type{Accuracy}, hi::T) where {T<:AbstractFloat} = Double{T, Accuracy}(hi, zero(T))
Double(::Type{Performance}, hi::T) where {T<:AbstractFloat} = Double{T, Performance}(hi, zero(T))
Double(::Type{Accuracy}, hi::T, lo::T) where {T<:AbstractFloat} = Double{T, Accuracy}(hi, lo)
Double(::Type{Performance}, hi::T, lo::T) where {T<:AbstractFloat} = Double{T, Performance}(hi, lo)
Double(x::T) where {T<:AbstractFloat} = Double{T, Accuracy}(x, zero(T))
Double(x::T, y::T) where {T<:AbstractFloat} = Double{T, Accuracy}(add_acc(x, y)...,)

FastDouble() = Double{Float64, Performance}(zero(Float64), zero(Float64))
FastDouble(x::T) where {T<:AbstractFloat} = Double{T, Performance}(x, zero(T))
FastDouble(x::T, y::T) where {T<:AbstractFloat} = Double{T, Performance}(add_acc(x, y)...,)

# a type specific fast hash function helps
const hash_doublefloat_lo = (UInt === UInt64) ? 0x9bad5ebab034fe78 : 0x72da40cb
const hash_0_doublefloat_lo = hash(zero(UInt), hash_doublefloat_lo)
Base.hash(z::Double{T,E}, h::UInt) where {T,E<:Emphasis} =
    hash(unsigned(z.hi) ⊻ unsigned(z.lo),
         (h, hash(T) ⊻ hash(E)) ⊻ hash_0_doublefloat_lo))

include("predicates.jl")
include("string_show.jl")



import Base: (+), (-), (*), (/), inv #square, inv, div, rem, cld, fld, mod, divrem, fldmod, sqrt,

@inline (+)(a::Double{F1,E}, b::Double{F2,E}) where {E<:Emphasis, F1<:AbstractFloat, F2<:AbstractFloat} =
    (+)(E, promote(a, b)...)

# Algorithm 6 from Tight and rigourous error bounds for basic building blocks of double-word arithmetic
function (+)(x::Double{T, E}, y::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
    hi, lo = two_sum(x.hi, y.hi)
    thi, tlo = two_sum(x.lo, y.lo)
    c = lo + thi
    hi, lo = two_sum_hilo(hi, c)
    c = tlo + lo
    hi, lo = two_sum_hilo(hi, c)
    return Double{T,E}(hi, lo)
end

# Algorithm 6 from Tight and rigourous error bounds for basic building blocks of double-word arithmetic
function add_dd_dd(xhi::T, xlo::T, yhi::T, ylo::T) where T<:AbstractFloat
    hi, lo = two_sum(xhi, yhi)
    thi, tlo = two_sum(xlo, ylo)
    c = lo + thi
    hi, lo = two_sum_hilo(hi, c)
    c = tlo + lo
    hi, lo = two_sum_hilo(hi, c)
    return hi, lo
end

@inline (-)(a::Double{F1,E}, b::Double{F2,E}) where {E<:Emphasis, F1<:AbstractFloat, F2<:AbstractFloat} =
    (-)(E, promote(a, b)...)

# Algorithm 6 from Tight and rigourous error bounds for basic building blocks of double-word arithmetic
# reworked for subraction
function (-)(x::Double{T, E}, y::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
    hi, lo = two_diff(x.hi, y.hi)
    thi, tlo = two_diff(x.lo, y.lo)
    c = lo + thi
    hi, lo = two_sum_hilo(hi, c)
    c = tlo + lo
    hi, lo = two_sum_hilo(hi, c)
    return Double{T,E}(hi, lo)
end

# Algorithm 6 from Tight and rigourous error bounds for basic building blocks of double-word arithmetic
# reworked for subtraction
function sub_dd_dd(xhi::T, xlo::T, yhi::T, ylo::T) where T<:AbstractFloat
    hi, lo = two_diff(xhi, yhi)
    thi, tlo = two_diff(xlo, ylo)
    c = lo + thi
    hi, lo = two_sum_hilo(hi, c)
    c = tlo + lo
    hi, lo = two_sum_hilo(hi, c)
    return hi, lo
end

#=
theoretical relerr <= 5*(u^2)
experimental relerr ldexp(3.936,-106) == ldexp(1.968, -107)
=#

# Algorithm 12 from Tight and rigourous error bounds for basic building blocks of double-word arithmetic
function prod_dd_dd(xhi::T, xlo::T, yhi::T, ylo::T) where T<:AbstractFloat
    hi, lo = two_prod(xhi, yhi)
    t = xlo * ylo
    t = fma(xhi, ylo, t)
    t = fma(xlo, yhi, t)
    t = lo + t
    hi, lo = two_sum_hilo(hi, t)
    return hi, lo
end

# Algorithm 12 from Tight and rigourous error bounds for basic building blocks of double-word arithmetic
function (*)(x::Double{T,E}, y::Double{T,E}) where {T<:AbstractFloat,E<:Emphasis}
    hi, lo = two_prod(x.hi, y.hi)
    t = x.lo * y.lo
    t = fma(x.hi, y.lo, t)
    t = fma(x.lo, y.hi, t)
    t = lo + t
    hi, lo = two_sum_hilo(hi, t)
    return Double{T,E}(hi, lo)
end

function (sqr)(x::Double{T,E}) where {T<:AbstractFloat,E<:Emphasis}
    hi, lo = two_prod(x.hi, x.hi)
    t = x.lo * x.lo
    t = fma(x.hi, x.lo, t)
    t = fma(x.lo, x.hi, t)
    t = lo + t
    hi, lo = two_sum_hilo(hi, t)
    return Double{T,E}(hi, lo)
end


function (/)(a::Double{T,Performance}, b::Double{T,Performance}) where {T<:AbstractFloat}
    hi1 = a.hi / b.hi
    hi, lo = prod_dd_fl(b.hi, b.lo, hi1)
    xhi, xlo = two_sum(a.hi, -hi)
    xlo -= lo
    xlo += a.lo
    hi2 = (xhi + xlo) / b.hi
    hi, lo = two_sum(hi1, hi2)
    return Double{T,Performance}(hi, lo)
end

#=
# Algorithm 18 from Tight and rigourous error bounds for basic building blocks of double-word arithmetic
function (/)(x::Double{T,Accuracy}, y::Double{T,Accuracy}) where {T<:SysFloat}
    hi = inv(y.hi)
    rhi = fma(-y.hi, hi, one(T))
    rlo = y.lo * hi
    rhi, rlo = two_sum_hilo(rhi, rlo)
    rhi, rlo = prod_dd_fl(rhi, rlo, hi)
    rhi, rlo = add_dd_fl(rhi, rlo, hi)
    hi, lo = prod__dd_dd(x.hi, x.lo, rhi, rlo)
    return Double(hi, lo)
end
=#

function (/)(a::Double{T,Accuracy}, b::Double{T,Accuracy}) where {T<:AbstractFloat}
    q1 = a.hi / b.hi
    th,tl = prod_dd_fl(b.hi,b.lo,q1)
    rh,rl = add_dd_dd(a.hi, a.lo, -th,-tl)
    q2 = rh / b.hi
    th,tl = prod_dd_fl(b.hi,b.lo,q2)
    rh,rl = add_dd_dd(rh, rl, -th,-tl)
    q3 = rh / b.hi
    q1, q2 = two_sum_hilo(q1, q2)
    rh,rl = add_dd_fl(q1, q2, q3)
    return Double{T,Accuracy}(rh, rl)
end

@inline (/)(a::Double{F1,E}, b::Double{F2,E}) where {E<:Emphasis, F1<:AbstractFloat, F2<:AbstractFloat} = (/)(E, a, b)

inv(x::Double{T, E}) where {T<:AbstractFloat, E<:Emphasis} = one(T)/x

