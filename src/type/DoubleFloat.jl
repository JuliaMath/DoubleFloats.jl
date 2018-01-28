abstract type AbstractDouble{T}    <: MultipartFloat{T} end

struct Double{T<:AbstractFloat, E<:Emphasis} <: AbstractDouble{T}
    hi::T
    lo::T
end

@inline hi(x::Double{T,E}) where {T,E<:Emphasis} = x.hi
@inline lo(x::Double{T,E}) where {T,E<:Emphasis} = x.lo

@inline hi(x::T) where {T<:AbstractFloat} = x
@inline lo(x::T) where {T<:AbstractFloat} = zero(T)





include("string_show.jl")
