@inline function rootn_dbsi_db(x::DoubleFloat{T}, n::Signed) where {T<:AbstractFloat}
    return DoubleFloat(rootn_ddsi_dd(HILO(x), n))
end
