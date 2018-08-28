@inline function add_dbfp_db(x::DoubleFloat{T}, y::T) where {T<:AbstractFloat}
    res = DoubleFloat{T}(add_ddfp_dd(HILO(x), y))
    isnan(HI(res))  ? add_dbfp_db_nonfinite(x,y) : res
end

@inline function sub_dbfp_db(x::DoubleFloat{T}, y::T) where {T<:AbstractFloat}
    res = DoubleFloat{T}(sub_ddfp_dd(HILO(x), y))
    isnan(HI(res))  ? sub_dbfp_db_nonfinite(x,y) : res
end

@inline function mul_dbfp_db(x::DoubleFloat{T}, y::T) where {T<:AbstractFloat}
    res = DoubleFloat{T}(mul_ddfp_dd(HILO(x), y))
    isnan(HI(res))  ? mul_dbfp_db_nonfinite(x,y) : res
end

@inline function dvi_dbfp_db(x::DoubleFloat{T}, y::T) where {T<:AbstractFloat}
    res = DoubleFloat{T}(dvi_ddfp_dd(HILO(x), y))
    isnan(HI(res))  ? dvi_dbfp_db_nonfinite(x,y) : res
end


@inline function add_dbfp_db_nonfinite(x::DoubleFloat{T}, y::T) where {T<:AbstractFloat}
    z = HI(x) + y
    return DoubleFloat(z, zero(T))
end

@inline function sub_dbfp_db_nonfinite(x::DoubleFloat{T}, y::T) where {T<:AbstractFloat}
    z = HI(x) - y
    return DoubleFloat(z, zero(T))
end

@inline function mul_dbfp_db_nonfinite(x::DoubleFloat{T}, y::T) where {T<:AbstractFloat}
    z = HI(x) * y
    return DoubleFloat(z, zero(T))
end

@inline function dvi_dbfp_db_nonfinite(x::DoubleFloat{T}, y::T) where {T<:AbstractFloat}
    z = div(HI(x), y)
    return DoubleFloat(z, zero(T))
end
