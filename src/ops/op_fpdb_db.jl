inline function add_fpdb_db(x::T, y::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
    yhi, ylo = HILO(y)
    yhi, ylo = add_2(x, yhi, ylo)
    return Double(E, yhi, ylo)
end

@inline function sub_fpdb_db(x::T, y::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
    yhi, ylo = HILO(y)
    yhi, ylo = add_2(-x, yhi, ylo)
    return Double(E, yhi, ylo)
end

@inline function mul_fpdb_db(x::T, y::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
    yhi, ylo = HILO(y)
    yhi, ylo = mul_2(x, yhi, ylo)
    return Double(E, yhi, ylo)
end

@inline function dve_fpdb_db(x::T, y::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
    yhi, ylo = HILO(y)
    xinv = inv(x)
    yhi, ylo = mul_2(xinv, yhi, ylo)
    return Double(E, yhi, ylo)
end
