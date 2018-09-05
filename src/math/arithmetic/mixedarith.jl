Base.sum(x::DoubleFloat{T}, xs::F...) where {T<:IEEEFloat, F<:Union{IEEEFloat, Signed}}  = sum(x, DoubleFloat{T}.(xs...,))
Base.prod(x::DoubleFloat{T}, xs::F...) where {T<:IEEEFloat, F<:Union{IEEEFloat, Signed}}  = prod(x, DoubleFloat{T}.(xs...,))
