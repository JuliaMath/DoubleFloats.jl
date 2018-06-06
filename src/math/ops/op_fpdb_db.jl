@inline function add_fpdb_db(x::T, y::DoubleFloat{T}) where {T<:AbstractFloat}
    !(isfinite(x) & isfinite(y)) && return add_fpdb_db_nonfinite(x,y)
    hi, lo = add_fpdd_dd(x, HILO(y))
    return DoubleFloat(hi, lo)
end

@inline function sub_fpdb_db(x::T, y::DoubleFloat{T}) where {T<:AbstractFloat}
    !(isfinite(x) & isfinite(y)) && return sub_fpdb_db_nonfinite(x,y)
    hi, lo = sub_fpdd_dd(x, HILO(y))
    return DoubleFloat(hi, lo)
end

@inline function mul_fpdb_db(x::T, y::DoubleFloat{T}) where {T<:AbstractFloat}
    !(isfinite(x) & isfinite(y)) && return mul_fpdb_db_nonfinite(x,y)
    hi, lo = mul_fpdd_dd(x, HILO(y))
    return DoubleFloat(hi, lo)
end

@inline function dvi_fpdb_db(x::T, y::DoubleFloat{T}) where {T<:AbstractFloat}
    !(isfinite(x) & isfinite(y)) && return dvi_fpdb_db_nonfinite(x,y)
    hi, lo = dvi_fpdd_dd(x, HILO(y))
    return DoubleFloat(hi, lo)
end


@inline function add_fpdb_db_nonfinite(x::T, y::DoubleFloat{T}) where {T<:AbstractFloat}
    z = x + HI(y)
    return DoubleFloat(z, zero(T))
end

@inline function sub_fpdb_db_nonfinite(x::T, y::DoubleFloat{T}) where {T<:AbstractFloat}
    z = x - HI(y)
    return DoubleFloat(z, zero(T))
end

@inline function mul_fpdb_db_nonfinite(x::T, y::DoubleFloat{T}) where {T<:AbstractFloat}
    z = x * HI(y)
    return DoubleFloat(z, zero(T))
end

@inline function dvi_fpdb_db_nonfinite(x::T, y::DoubleFloat{T}) where {T<:AbstractFloat}
    z = div(x, HI(y))
    return DoubleFloat(z, zero(T))
end
