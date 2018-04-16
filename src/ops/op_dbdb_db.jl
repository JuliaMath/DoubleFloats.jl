@inline function add_dbdb_db(x::Double{T,E}, y::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
    !(isfinite(x) & isfinite(y)) && return add_dbdb_db_nonfinite(x,y)
    hi, lo = add_dddd_dd(HILO(x), HILO(y))
    return Double(E, hi, lo)
end

@inline function sub_dbdb_db(x::Double{T,E}, y::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
    !(isfinite(x) & isfinite(y)) && return sub_dbdb_db_nonfinite(x,y)
    hi, lo = sub_dddd_dd(HILO(x), HILO(y))
    return Double(E, hi, lo)
end

@inline function mul_dbdb_db(x::Double{T,E}, y::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
    !(isfinite(x) & isfinite(y)) && return mul_dbdb_db_nonfinite(x,y)
    hi, lo = mul_dddd_dd(HILO(x), HILO(y))
    return Double(E, hi, lo)
end

@inline function dvi_dbdb_db(x::Double{T, Accuracy}, y::Double{T, Accuracy}) where {T<:AbstractFloat}
    !(isfinite(x) & isfinite(y)) && return dvi_dbdb_db_nonfinite(x,y)
    hi, lo = dvi_dddd_dd(HILO(x), HILO(y))
    return Double(Accuracy, hi, lo)
end

@inline function dvi_dbdb_db(x::Double{T, Performance}, y::Double{T, Performance}) where {T<:AbstractFloat}
    !(isfinite(x) & isfinite(y)) && return dvi_dbdb_db_nonfinite(x,y)
    hi, lo = dvi_dddd_dd_fast(HILO(x), HILO(y))
    return Double(Performance, hi, lo)
end


@inline function add_dbdb_db_nonfinite(x::Double{T,E}, y::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
    z = HI(x) + HI(y)
    return Double(E, z, zero(T))
end

@inline function sub_dbdb_db_nonfinite(x::Double{T,E}, y::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
    z = HI(x) - HI(y)
    return Double(E, z, zero(T))
end

@inline function mul_dbdb_db_nonfinite(x::Double{T,E}, y::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
    z = HI(x) * HI(y)
    return Double(E, z, zero(T))
end

@inline function dvi_dbdb_db_nonfinite(x::Double{T,E}, y::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
    z = div(HI(x), HI(y))
    return Double(E, z, zero(T))
end
