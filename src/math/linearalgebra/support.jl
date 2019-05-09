@inline function issquare(m::AbstractArray{T,2}) where {T<:Number}
    r, c = size(m)
    return r === c
end

@inline function issquare(m::Array{DoubleFloat{T},2}) where {T<:IEEEFloat}
    r, c = size(m)
    return r === c
end

function norm(v::Array{DoubleFloat{T},N}) where {N, T<:IEEEFloat}
    v = v .* v
    return sqrt(sum(v))
end

function norm(v::Array{DoubleFloat{T},N}, p::R) where {N, T<:IEEEFloat, R<:Real}
    v = v .* v
    r = inv(DoubleFloat{T}(p))
    return (sum(v))^r
end
