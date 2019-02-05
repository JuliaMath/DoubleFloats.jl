@inline function issquare(m::AbstractArray{T,2}) where {T<:Number}
    r, c = size(m)
    return r === c
end

@inline function issquare(m::Array{DoubleFloat{T},2}) where {T<:IEEEFloat}
    r, c = size(m)
    return r === c
end
