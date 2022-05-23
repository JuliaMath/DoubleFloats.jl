@inline function rootn_dbsi_db(x::DoubleFloat{T}, n::Signed) where {T<:IEEEFloat}
    isfinite(HI(y)^(1/n)) && return DoubleFloat{T}(rootn_ddsi_dd(HILO(x), n))
    rootn_dd_dd_nonfinite(HILO(x), n)
end
