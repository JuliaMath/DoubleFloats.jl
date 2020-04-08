@inline function issquare(m::AbstractArray{T,2}) where {T<:Number}
    r, c = size(m)
    return r === c
end

@inline function issquare(m::Array{DoubleFloat{T},2}) where {T<:IEEEFloat}
    r, c = size(m)
    return r === c
end

function norm(v::Array{DoubleFloat{T},N}, p::Real=2.0) where {N, T<:IEEEFloat}
    isempty(v) && return zero(DoubleFloat{T})

    if isinf(p)
        return signbit(p) ? minimum(abs.(v)) : maximum(abs.(v))
    elseif p==2
        return vp = sqrt(sum(v .* v))
    else    
        vp = sum((v).^(p))
        r = inv(DoubleFloat{T}(p))
        return vp^r
    end    
end

function norm(v::Array{Complex{DoubleFloat{T}},N}, p::Real=2.0) where {N, T<:IEEEFloat}
    isempty(v) && return zero(DoubleFloat{T})

    if isinf(p)
        return signbit(p) ? minimum(abs.(real.(v))) : maximum(abs.(real.(v)))
    elseif p==2
        return vp = sqrt(real(sum(conj.(v) .* v)))
    else    
        vp = sum(abs.(v).^(p))
        r = inv(DoubleFloat{T}(p))
        return vp^r
    end    
end

function LinearAlgebra.normalize(v::Array{DoubleFloat{T},N}, p::Real=2.0) where {N, T<:IEEEFloat}
    return v ./ norm(v, p)
end

function LinearAlgebra.normalize(v::Array{Complex{DoubleFloat{T}},N}, p::Real=2.0) where {N, T<:IEEEFloat}
    return v ./ norm(v, p)
end
