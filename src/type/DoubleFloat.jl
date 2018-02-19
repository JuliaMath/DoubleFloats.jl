import Base: Float16, Float32, Float64, BigFloat

struct Double{T, E<:Emphasis} <: AbstractDouble{T}
    hi::T
    lo::T
end

@inline HI(x::Double{T,E}) where {T,E<:Emphasis} = x.hi
@inline LO(x::Double{T,E}) where {T,E<:Emphasis} = x.lo
@inline HILO(x::Double{T,E}) where {T,E<:Emphasis} = (x.hi, x.lo)

@inline HI(x::Tuple{T,T}) where {T} = x[1]
@inline LO(x::Tuple{T,T}) where {T} = x[2]
@inline HILO(x::Tuple{T,T}) where {T} = x

@inline HI(x::T) where {T<:AbstractFloat} = x
@inline LO(x::T) where {T<:AbstractFloat} = zero(T)
@inline HILO(x::T) where {T<:AbstractFloat} = (x, zero(T))

# initializers

Double() = Double{Float64, Accuracy}(zero(Float64), zero(Float64))

Double{T, E}(x::T) where {T<:AbstractFloat, E<:Emphasis} = Double{T, E}(x, zero(T))

Double(::Type{Accuracy}) = Double{Float64, Accuracy}(zero(Float64), zero(Float64))
Double(::Type{Performance}) = Double{Float64, Performance}(zero(Float64), zero(Float64))
Double(::Type{Accuracy}, hi::T) where {T<:AbstractFloat} = Double{T, Accuracy}(hi, zero(T))
Double(::Type{Performance}, hi::T) where {T<:AbstractFloat} = Double{T, Performance}(hi, zero(T))
Double(::Type{Accuracy}, hi::T, lo::T) where {T<:AbstractFloat} = Double{T, Accuracy}(hi, lo)
Double(::Type{Performance}, hi::T, lo::T) where {T<:AbstractFloat} = Double{T, Performance}(hi, lo)

Double(x::T) where {T<:IEEEFloat} = Double{T, Accuracy}(x, zero(Float64))
Double(x::T) where {T<:Union{Int16, Int32, Int64}} = Double(Float64(x))

Double(x::T) where {T<:String} =
    Double{Float64, Accuracy}(Float64(x), zero(Float64))

Double(::Type{Accuracy}, hi::T) where {T<:Signed} =
    Double{T, Accuracy}(float(hi), zero(typeof(float(hi))))
Double(::Type{Performance}, hi::T) where {T<:Signed} =
    Double{T, Performance}(float(hi), zero(typeof(float(hi))))
Double(::Type{Accuracy}, hi::T, lo::T) where {T<:Signed} =
    Double{T, Accuracy}(float(hi), float(lo))
Double(::Type{Performance}, hi::T, lo::T) where {T<:Signed} =
    Double{T, Performance}(float(hi), float(lo))

Double(x::T) where {T<:Signed} =
    Double{Float64, Accuracy}(float(x), zero(typeof(float(x))))
Double(x::T, y::T) where {T<:Signed} =
    Double{Float64, Accuracy}(add_(float(x), float(y))...,)

@inline Double{T, E}(hilo::Tuple{T, T}) where {T<:AbstractFloat, E<:Emphasis} =
    Double{T, E}(hilo[1], hilo[2])

@inline Double(::Type{Accuracy}, hi::T, lo::T) where {T<:AbstractFloat} =
    Double{T, Accuracy}(hi, lo)
@inline Double(::Type{Performance}, hi::T, lo::T) where {T<:AbstractFloat} =
    Double{T, Performance}(hi, lo)
@inline Double(::Type{Accuracy}, hilo::Tuple{T,T}) where {T<:AbstractFloat} =
    Double{T, Accuracy}(hilo[1], hilo[2])
@inline Double(::Type{Performance}, hilo::Tuple{T,T}) where {T<:AbstractFloat} =
    Double{T, Performance}(hilo[1], hilo[2])


for T in (:Float64, :Float32, :Float16)
  @eval begin
    $T(x::Double{$T, E}) where E<:Emphasis = HI(x)
  end
end
Float32(x::Double{Float64, E}) where E<:Emphasis = Float32(HI(x))
Float16(x::Double{Float64, E}) where E<:Emphasis = Float16(HI(x))
Float16(x::Double{Float32, E}) where E<:Emphasis = Float16(HI(x))

function BigFloat(x::Double{T, E}, p=precision(BigFloat)) where {T<:AbstractFloat, E<:Emphasis}
    BigFloat(HI(x), p) + BigFloat(LO(x), p)
end

function Double{T, E}(x::BigFloat) where {T<:AbstractFloat, E<:Emphasis}
    hi = T(x)
    lo = T(x-hi)
    return Double{T, E}(hi, lo)
end

function Double{T, E}(x::BigInt) where {T<:AbstractFloat, E<:Emphasis}
    return Double{T, E}(BigFloat(x))
end

function Double{T,E}(x::Irrational{S}) where {S, T<:AbstractFloat, E<:Emphasis}
    y = BigFloat(x)
    return Double{T,E}(y)
end

function Double{T,E}(x::Type{Rational{I}}) where {I<:Signed, T<:AbstractFloat, E<:Emphasis}
    numer = Double{T,E}(numerator(x))
    denom = Double{T,E}(denominator(x))
    return numer/denom
end

FastDouble() = Double{Float64, Performance}(zero(Float64), zero(Float64))
FastDouble(x::T) where {T<:AbstractFloat} =
    Double{Float64, Performance}(x, zero(Float64))
FastDouble(x::T, y::T) where {T<:AbstractFloat} =
    Double{Float64, Performance}(add_(x, y)...,)

FastDouble(x::T) where {T<:Real} =
    FastDouble{Float64, Performance}(Float64(x), zero(Float64))
FastDouble(x::T, y::T) where {T<:Real} =
    FastDouble{Float64, Performance}(add_(convert(Float64,x), convert(Float64,y))...,)

# a fast type specific hash function helps
import Base: hash, hx, fptoui

const hash_doublefloat_lo = (UInt === UInt64) ? 0x9bad5ebab034fe78 : 0x72da40cb
const hash_0_dfloat_lo = hash(zero(UInt), hash_doublefloat_lo)
const hash_accuracy_lo = hash(hash(Accuracy), hash_doublefloat_lo)
const hash_performance_lo = hash(hash(Performance), hash_doublefloat_lo)

function hash(x::Double{T,Accuracy}, h::UInt) where {T}
    !isnan(HI(x)) ?
       ( iszero(LO(x)) ?
            hx(fptoui(UInt64, abs(HI(x))), HI(x), h ⊻ hash_accuracy_lo) :
            hx(fptoui(UInt64, abs(HI(x))), LO(x), h ⊻ hash_accuracy_lo)
       ) : (hx_NaN ⊻ h)
end

function hash(x::Double{T,Performance}, h::UInt) where {T}
    !isnan(HI(x)) ?
       ( iszero(LO(x)) ?
            hx(fptoui(UInt64, abs(HI(x))), HI(x), h ⊻ hash_performance_lo) :
            hx(fptoui(UInt64, abs(HI(x))), LO(x), h ⊻ hash_performance_lo)
       ) : (hx_NaN ⊻ h)
end


include("val_isa_cmp.jl")
include("string_show.jl")
