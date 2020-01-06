function ellipk(x::DoubleFloat{T}) where {T<:IEEEFloat}
    !(-0.0 <= x <= 1.0) && throw(DomainError("$x not in 0..1"))
    x === one(T) && return DoubleFloat{T}(Inf)

    df_one    = one(DoubleFloat{T})
    df_halfpi = DoubleFloat{T}(pi)/2
        
    k = sqrt(abs(x - df_one))
    k = agm1(k)
    k = df_halfpi / k

    return k
end
