@inline function rootn_dbsi_db(x::DoubleFloat{T}, n::Signed) where {T<:AbstractFloat}
    hi, lo = rootn_ddsi_dd(HILO(x), n)
    return DoubleFloat(hi, lo)
end
