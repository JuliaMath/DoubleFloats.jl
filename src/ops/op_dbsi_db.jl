@inline function rootn_dbsi_db(x::Double{T,E}, n::Signed) where {T<:AbstractFloat, E<:Emphasis}
    hi, lo = rootn_ddsi_dd(HILO(x), n)
    return Double(E, hi, lo)
end
