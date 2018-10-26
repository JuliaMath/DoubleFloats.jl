@inline function add_fpdb_db(x::T, y::DoubleFloat{T}) where {T<:AbstractFloat}
    res = DoubleFloat{T}(add_fpdd_dd(x, HILO(y)))
    return !isnan(HI(res))  ? res : add_fpdb_db_nonfinite(x,y)
end

@inline function sub_fpdb_db(x::T, y::DoubleFloat{T}) where {T<:AbstractFloat}
    res = DoubleFloat{T}(sub_fpdd_dd(x, HILO(y)))
    return !isnan(HI(res))  ? res : sub_fpdb_db_nonfinite(x,y)
end

@inline function mul_fpdb_db(x::T, y::DoubleFloat{T}) where {T<:AbstractFloat}
    res = DoubleFloat{T}(mul_fpdd_dd(x, HILO(y)))
    return !isnan(HI(res))  ? res : mul_fpdb_db_nonfinite(x,y)
end

@inline function dvi_fpdb_db(x::T, y::DoubleFloat{T}) where {T<:AbstractFloat}
    res = DoubleFloat{T}(dvi_fpdd_dd(x, HILO(y)))
    return !isnan(HI(res))  ? res : dvi_fpdb_db_nonfinite(x,y)
end


@inline function add_fpdb_db_nonfinite(x::T, y::DoubleFloat{T}) where {T<:AbstractFloat}
    z = x + HI(y)
    return DoubleFloat{T}(z, zero(T))
end

@inline function sub_fpdb_db_nonfinite(x::T, y::DoubleFloat{T}) where {T<:AbstractFloat}
    z = x - HI(y)
    return DoubleFloat{T}(z, zero(T))
end

@inline function mul_fpdb_db_nonfinite(x::T, y::DoubleFloat{T}) where {T<:AbstractFloat}
    z = x * HI(y)
    return DoubleFloat{T}(z, zero(T))
end

@inline function dvi_fpdb_db_nonfinite(x::T, y::DoubleFloat{T}) where {T<:AbstractFloat}
    z = div(x, HI(y))
    return DoubleFloat{T}(z, zero(T))
end
