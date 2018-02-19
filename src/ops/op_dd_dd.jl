@inline function abs_dd_dd(x::Tuple{T,T}) where {T<:AbstractFloat}
    hi, lo = x
    if signbit(hi)
        hi = -hi
        lo = -lo
    end
    return hi, lo
end

@inline function neg_dd_dd(x::Tuple{T,T}) where {T<:AbstractFloat}
    hi, lo = x
    hi = -hi
    lo = -lo
    return hi, lo
end

@inline function negabs_dd_dd(x::Tuple{T,T}) where {T<:AbstractFloat}
    hi, lo = x
    if !signbit(hi)
        hi = -hi
        lo = -lo
    end
    return hi, lo
end
