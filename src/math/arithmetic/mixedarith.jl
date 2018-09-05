Base.sum(x::DoubleFloat{T}, xs::F...) where {T<:IEEEFloat, Union{IEEEFloat, Signed}}  = sum(x, DoubleFloat{T}.(xs...,))
Base.prod(x::DoubleFloat{T}, xs::F...) where {T<:IEEEFloat, Union{IEEEFloat, Signed}}  = prod(x, DoubleFloat{T}.(xs...,))
