@inline function add_fpdb_db(x::T, y::DoubleFloat{T}) where {T<:AbstractFloat}
    res = DoubleFloat(add_fpdd_dd(x, HILO(y)))
    isnan(HI(res))  ? add_fpdb_db_nonfinite(x,y) : res
end

@inline function sub_fpdb_db(x::T, y::DoubleFloat{T}) where {T<:AbstractFloat}
    res = DoubleFloat(sub_fpdd_dd(x, HILO(y)))
    isnan(HI(res))  ? sub_fpdb_db_nonfinite(x,y) : res
end

@inline function mul_fpdb_db(x::T, y::DoubleFloat{T}) where {T<:AbstractFloat}
    res = DoubleFloat(mul_fpdd_dd(x, HILO(y)))
    isnan(HI(res))  ? mul_fpdb_db_nonfinite(x,y) : res
end

@inline function dvi_fpdb_db(x::T, y::DoubleFloat{T}) where {T<:AbstractFloat}
    res = DoubleFloat(dvi_fpdd_dd(x, HILO(y)))
    isnan(HI(res))  ? dvi_fpdb_db_nonfinite(x,y) : res
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
