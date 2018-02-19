
@inline function add_dbdb_db(x::Double{T,E}, y::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
    hi, lo = add_dddd_dd(HILO(x), HILO(y))
    return Double(E, hi, lo)
end

@inline function sub_dbdb_db(x::Double{T,E}, y::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
    hi, lo = sub_dddd_dd(HILO(x), HILO(y))
    return Double(E, hi, lo)
end

@inline function mul_dbdb_db(x::Double{T,E}, y::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
    hi, lo = mul_dddd_dd(HILO(x), HILO(y))
    return Double(E, hi, lo)
end

@inline function dvi_dbdb_db(x::Double{T,Accuracy}, y::Double{T,Accuracy}) where {T<:AbstractFloat}
    hi, lo = dvi_dddd_dd(HILO(x), HILO(y))
    return Double(Accuracy, hi, lo)
end

@inline function dvi_dbdb_db(x::Double{Performance,E}, y::DoubleTTTPerformance}) where {T<:AbstractFloat}
    hi, lo = dvi_dddd_dd_fast(HILO(x), HILO(y))
    return Double(Performance, hi, lo)
end

