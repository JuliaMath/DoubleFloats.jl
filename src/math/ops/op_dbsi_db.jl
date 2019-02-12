@inline function rootn_dbsi_db(x::DoubleFloat{T}, n::Signed) where {T<:IEEEFloat}
    return DoubleFloat{T}(rootn_ddsi_dd(HILO(x), n))
end
