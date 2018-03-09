@inline function add_dbfp_db(x::Double{T,E}, y::T) where {T<:AbstractFloat, E<:Emphasis}
    hi, lo = add_ddfp_dd(HILO(x), y)
    return Double(E, hi, lo)
end

@inline function sub_dbfp_db(x::Double{T,E}, y::T) where {T<:AbstractFloat, E<:Emphasis}
    hi, lo = sub_ddfp_dd(HILO(x), y)
    return Double(E, hi, lo) 
end

@inline function mul_dbfp_db(x::Double{T,E}, y::T) where {T<:AbstractFloat, E<:Emphasis}
    hi, lo = mul_ddfp_dd(HILO(x), y)
    return Double(E, hi, lo)
end

@inline function dvi_fpdb_db(x::T, y::Double{T,Accuracy}) where {T<:AbstractFloat}
    hi, lo = dvi_fpdd_dd(x, HILO(y))
    return Double(Accuracy, hi, lo)
end

@inline function dvi_fpdb_db(x::T, y::Double{T,Performance}) where {T<:AbstractFloat}
    hi, lo = dvi_fpdd_dd_fast(x, HILO(y))
    return Double(Performance, hi, lo)
end
