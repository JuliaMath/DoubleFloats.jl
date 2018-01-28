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



include("type/values_predicates.jl")
include("type/string_show.jl")
