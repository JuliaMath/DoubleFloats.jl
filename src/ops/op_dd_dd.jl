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

@inline function inv_dd_dd(x::Tuple{T,T}) where {T<:AbstractFloat}
    hi, lo = x
    a = one(T)

    q0 = 1.0 / hi
    #r = a - (x * q0)
    #    a - ((hi+lo)*q0)
    #    a - hi*q0 - lo*q0
    r  = fma(-hi,q0,a) - lo*q0
    #q1 = HI(r) / hi
    q1 = r/hi
    #r = r - (x * q1)
    r  = fma(-hi,q1,a) - lo*q1
    #q2 = HI(r) / hi
    q2 = r/hi
    q1, q2 = add_2(q1, q2)

    return q0, q2
end
