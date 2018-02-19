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

function inv_dd_dd(x::Tuple{T,T}) where {T<:AbstractFloat}
    t0 = zero(T)
    t1 = one(T)
    tuple1 = (t1, t0)
    hi, lo = x
    invhi = inv(hi)
    est = (invhi, t0)
    thilo = mul_dddd_dd(est, x)  
    err = sub_dddd_dd(tuple1, thilo)
    esterr = mul_dddd_dd(est, err)
    est = add_dddd_dd(est, esterr)
    thilo = mul_dddd_dd(est, x)  
    err = sub_dddd_dd(tuple1, thilo) 
    esterr = mul_dddd_dd(est, err)
    est = add_dddd_dd(est, esterr)
    return est
end
