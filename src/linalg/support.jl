@inline function issquare(m::AbstractArray{T,2}) where {T<:Number}
    r, c = size(m)
    return r === c
end
