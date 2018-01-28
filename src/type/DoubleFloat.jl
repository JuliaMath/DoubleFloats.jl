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
FastDouble(::Type{Accuracy})   = Double{Float64, Performance}(zero(Float64), zero(Float64))
FastDouble(::Type{Performance}) = Double{Float64, Performance}(zero(Float64), zero(Float64))
FastDouble(::Type{Accuracy}, hi::T) where {T<:AbstractFloat} = Double{T, Performance}(hi, zero(T))
FastDouble(::Type{Performance}, hi::T) where {T<:AbstractFloat} = Double{T, Performance}(hi, zero(T))
FastDouble(::Type{Accuracy}, hi::T, lo::T) where {T<:AbstractFloat} = Double{T, Performance}(hi, lo)
FastDouble(::Type{Performance}, hi::T, lo::T) where {T<:AbstractFloat} = Double{T, Performance}(hi, lo)

include("string_show.jl")
