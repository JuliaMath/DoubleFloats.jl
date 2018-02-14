inline function add_dbfp_db(x::Double{T,E}, y::T) where {T<:AbstractFloat, E<:Emphasis}
    xhi, xlo = HILO(x)
    xhi, xlo = add_2(y, xhi, xlo)
    return Double(E, xhi, xlo)
end

@inline function sub_dbfp_db(x::Double{T,E}, y::T) where {T<:AbstractFloat, E<:Emphasis}
    xhi, xlo = HILO(x)
    xhi, xlo = add_2(-y, xhi, xlo)
    return Double(E, xhi, xlo)
end

@inline function mul_dbfp_db(x::Double{T,E}, y::T) where {T<:AbstractFloat, E<:Emphasis}
    xhi, xlo = HILO(x)
    xhi, xlo = mul_2(y, xhi, xlo)
    return Double(E, xhi, xlo)
end

@inline function dve_dbfp_db(x::Double{T,E}, y::T) where {T<:AbstractFloat, E<:Emphasis}
    xhi, xlo = HILO(x)
    yinv = inv(y)
    xhi, xlo = mul_2(yinv, xhi, xlo)
    return Double(E, xhi, xlo)
end
