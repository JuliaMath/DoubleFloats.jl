@inline function add_fpdb_db(x::T, y::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
    !(isfinite(x) & isfinite(y)) && return add_fpdb_db_nonfinite(x,y)
    hi, lo = add_fpdd_dd(x, HILO(y))
    return Double(E, hi, lo)
end

@inline function sub_fpdb_db(x::T, y::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
    !(isfinite(x) & isfinite(y)) && return sub_fpdb_db_nonfinite(x,y)
    hi, lo = sub_fpdd_dd(x, HILO(y))
    return Double(E, hi, lo)
end

@inline function mul_fpdb_db(x::T, y::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
    !(isfinite(x) & isfinite(y)) && return mul_fpdb_db_nonfinite(x,y)
    hi, lo = mul_fpdd_dd(x, HILO(y))
    return Double(E, hi, lo)
end

@inline function dvi_fpdb_db(x::T, y::Double{T,Accuracy}) where {T<:AbstractFloat}
    !(isfinite(x) & isfinite(y)) && return dvi_fpdb_db_nonfinite(x,y)
    hi, lo = dvi_fpdd_dd(x, HILO(y))
    return Double(Accuracy, hi, lo)
end

@inline function dvi_fpdb_db(x::T, y::Double{T,Performance}) where {T<:AbstractFloat}
    !(isfinite(x) & isfinite(y)) && return dvi_fpdb_db_nonfinite(x,y)
    hi, lo = dvi_fpdd_dd_fast(x, HILO(y))
    return Double(Performance, hi, lo)
end

@inline funcHI(y)tion add_fpdb_db_nonfinite(x::T, y::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
    z = x + HI(y)
    return Double(E, z, zero(Double{T,E}))
end

@inline function sub_fpdb_db_nonfinite(x::T, y::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
    z = x - HI(y)
    return Double(E, z, zero(Double{T,E}))
end

@inline function mul_fpdb_db_nonfinite(x::T, y::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
    z = x * HI(y)
    return Double(E, z, zero(Double{T,E}))
end

@inline function dvi_fpdb_db_nonfinite(x::T, y::Double{T,E) where {T<:AbstractFloat, E<:Emphasis}
    z = div(x, HI(y))
    return Double(E, z, zero(Double{T,E}))
end
