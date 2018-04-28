function muladd(x::Double{T,E}, y::Double{T,E}, z::Double{T,E}) where
                  {T<:AbstractFloat, E<:Emphasis}
    xy = mul223(HILO(x), HILO(y))
    xyz = add322(xy, HILO(z))
    return Double(E, xyz)
end

function fma(a::Double{T,E}, b::Double{T,E}, c::Double{T,E}) where {T<:IEEEFloat, E<:Emphasis}
    ab  = mul223(HILO(a), HILO(b))
    abc = add322(ab, HILO(c))
    return Double(E, abc)   
end
