
@inline function add_dbdb_db(x::Double{T,E}, y::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
    hi, lo = add_dddd_dd(HILO(x), HILO(y))
    return Double(E, hi, lo)
end

@inline function sub_dbdb_db(x::Double{T,E}, y::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
    hi, lo = sub_dddd_dd(HILO(x), HILO(y))
    return Double(E, hi, lo)
end

@inline function mul_dbdb_db(x::Double{T,E}, y::Double{T,E}) where {T<:AbstractFloat, E<:Performance}
    hi, lo = mul_dddd_dd(HILO(x), HILO(y))
    return Double(E, hi, lo)
end

@inline function dvi_dbdb_db(x::Double{T,E}, y::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
    yinv = inv_dd_dd(HILO(y))
    hi, lo = mul_dddd_dd(HILO(x), yinv)
    return Double(E, hi, lo)
end
