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


function inv_dd_dd_itr(x::Tuple{T,T}, est::Tuple{T,T}) where {T<:AbstractFloat}
    err = mul_dddd_dd(x, est)
    err = sub_dddd_dd((one(T), zero(T)), err)
    err = mul_dddd_dd(est, err)
    est = add_dddd_dd(est,err)
    return est
end
#=
function inv_dd_dd(x::Tuple{T,T}) where {T<:AbstractFloat}
    est = (inv(x[1]), zero(T))
    est = inv_dd_dd_itr(x, est)
    est = inv_dd_dd_itr(x, est)
    return est
end
=#
function inv_dd_dd(x::Tuple{T,T}) where {T<:AbstractFloat}
    return DWInvDW3(HI(x), LO(x)
end

@inline function inv_dd_dd_fast(y::Tuple{T,T}) where T<:AbstractFloat
    xhi, xlo = one(T), zero(T)
    yhi, ylo = y
    hi = xhi / yhi
    uh, ul = mul_2(hi, yhi)
    lo = ((((xhi - uh) - ul) + xlo) - hi*ylo)/yhi
    hi, lo = add_2(hi, lo)
    return hi, lo
end
#=
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
=#
