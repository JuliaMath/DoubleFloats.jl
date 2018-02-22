@inline function abs_db_db(x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
    hi, lo = abs_dd_dd(HILO(x))
    return Double(E, hi, lo)
end

@inline function neg_db_db(x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
    hi, lo = neg_dd_dd(HILO(x))
    return Double(E, hi, lo)
end

@inline function negabs_db_db(x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
    hi, lo = negabs_dd_dd(HILO(x))
    return Double(E, hi, lo)
end

@inline function inv_db_db(x::Double{T,Accuracy}) where {T<:AbstractFloat}
    hi, lo = inv_dd_dd(HILO(x))
    return Double(Accuracy, hi, lo)
end

@inline function inv_db_db(x::Double{T,Performance}) where {T<:AbstractFloat}
    hi, lo = inv_dd_dd_fast(HILO(x))
    return Double(Performance, hi, lo)
end

@inline function sqrt_db_db(x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
    hi, lo = sqrt_dd_dd(HILO(x))
    return Double(E, hi, lo)
end

@inline function square_db_db(x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
    hi, lo = square_dd_dd(HILO(x))
    return Double(E, hi, lo)
end

@inline function cbrt_db_db(x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
    hi, lo = cbrt_dd_dd(HILO(x))
    return Double(E, hi, lo)
end
