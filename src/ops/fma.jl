# T<:AbstractFloat

function muladd(a::Double{T,E}, b::Double{T,E}, c::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
    ab  = mul223(HILO(a), HILO(b))
    abc = add322(ab, HILO(c))
    return Double(E, abc)
end

# T<:IEEEFloat

function muladd(a::Double{T,E}, b::Double{T,E}, c::Double{T,E}) where {T<:IEEEFloat, E<:Emphasis}
    ab  = mul223(HILO(a), HILO(b))
    abc = add322(ab, HILO(c))
    return Double(E, abc)
end

function fma(a::Double{T,E}, b::Double{T,E}, c::Double{T,E}) where {T<:IEEEFloat, E<:Emphasis}
    ab  = mul223(HILO(a), HILO(b))
    abc = add322(ab, HILO(c))
    return Double(E, abc)   
end
