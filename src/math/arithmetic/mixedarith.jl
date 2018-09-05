Base.:(+)(x::DoubleFloat{T}, xs::Vector{F}) where {T<:IEEEFloat, F<:Union{IEEEFloat, Signed}}  = +(x, DoubleFloat{T}.(xs))
Base.:(*)(x::DoubleFloat{T}, xs::Vector{F}) where {T<:IEEEFloat, F<:Union{IEEEFloat, Signed}}  = *(x, DoubleFloat{T}.(xs))
