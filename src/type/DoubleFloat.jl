
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

# a fast type specific hash function helps

const hash_accuracy = hash(Accuracy)
const hash_performance = hash(Performance)

const hash_doublefloat_lo = (UInt === UInt64) ? 0x9bad5ebab034fe78 : 0x72da40cb
const hash_0_doublefloat_lo = hash(zero(UInt), hash_doublefloat_lo)

@inline function Base.hash(x::Double{T,Accuracy}, h::UInt) where {T}
    isnan(hi(x)) && return (hx_NaN ⊻ h)
    iszero(lo(x)) && return Base.hx(Base.fptoui(UInt64, abs(hi(x))), hi(x), h)
    Base.hx(hash_accuracy ⊻ Base.fptoui(UInt64, abs(hi(x))), lo(x), h ⊻ hash_0_doublefloat_lo)
end

@inline function Base.hash(x::Double{T,Performance}, h::UInt) where {T}
    isnan(hi(x)) && return (hx_NaN ⊻ h)
    iszero(lo(x)) && return Base.hx(Base.fptoui(UInt64, abs(hi(x))), hi(x), h)
    Base.hx(hash_performance ⊻ Base.fptoui(UInt64, abs(hi(x))), lo(x), h ⊻ hash_0_doublefloat_lo)
end

include("val_isa_cmp.jl")
include("string_show.jl")
