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
    return DWInvDW3(HI(x), LO(x))
end

@inline function inv_dd_dd_fast(y::Tuple{T,T}) where {T<:AbstractFloat}
    xhi, xlo = one(T), zero(T)
    yhi, ylo = y
    hi = xhi / yhi
    uh, ul = mul_2(hi, yhi)
    lo = ((((xhi - uh) - ul) + xlo) - hi*ylo)/yhi
    hi, lo = add_2(hi, lo)
    return hi, lo
end


function sqrt_dd_dd(x::Tuple{T,T}) where {T<:AbstractFloat}
    iszero(x) && return x
    signbit(x) && throw(DomainError("sqrt(x) expects x >= 0"))

    half = T(0.5)
    dhalf = Double{T,E}(half, zero(T))

    r = inv(sqrt(HI(x)))
    h = Double{T,E}(HI(x) * half, LO(x) * half)

    r2 = r * r
    hr2 = h * r2
    radj = dhalf - hr2
    radj = radj * r
    r = r + radj

    r2 = r * r
    hr2 = h * r2
    radj = dhalf - hr2
    radj = radj * r
    r = r + radj

    r = r * x

    return r
end
