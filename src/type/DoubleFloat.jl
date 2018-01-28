#=
    Emphasis is a proto-trait
    algorithmic Accuracy    is a trait, ako Emphasis
    algorithmic Performance is a trait, ako Emphasis
=#
include("emphasis.jl")

abstract type AbstractDouble{T<:AbstractFloat} <: MultipartFloat{T} end

struct Double{T, E<:Emphasis} <: AbstractDouble{T<::AbstractFloat}
    hi::T
    lo::T
end

@inline hi(x::Double{T,E}) where {T,E<:Emphasis} = x.hi
@inline lo(x::Double{T,E}) where {T,E<:Emphasis} = x.lo

@inline hi(x::T) where {T<:AbstractFloat} = x
@inline lo(x::T) where {T<:AbstractFloat} = zero(T)





include("string_show.jl")
