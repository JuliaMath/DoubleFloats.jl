@inline function issquare(m::AbstractArray{T,2}) where {T<:Number}
    r, c = size(m)
    return r === c
end

@inline function issquare(m::Array{DoubleFloat{T},2}) where {T<:IEEEFloat}
    r, c = size(m)
    return r === c
end

function norm(v::Array{DoubleFloat{T},N}) where {N, T<:IEEEFloat}
    return sqrt(sum(v .* v))
end

function norm(v::Array{DoubleFloat{T},N}, p::R) where {N, T<:IEEEFloat, R<:Real}
    if isinf(p)
        return signbit(p) ? minimum(v) : maximum(v)
    else
        vp = sum((v).^(p))
        r = inv(DoubleFloat{T}(p))
        return vp^r
    end    
end

function LinearAlgebra.normalize(v::Array{DoubleFloat{T},N}, p::R=2.0) where {N, T<:IEEEFloat, R<:Real}
    return v ./ norm(v, p)
end
