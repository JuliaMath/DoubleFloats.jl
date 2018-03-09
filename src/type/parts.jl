function intpart(x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
    hi, lo = HILO(x)
    ihi = modf(hi)[2]
    ilo = modf(lo)[2]
    return Double(E, (ihi, ilo))
end

function fracpart(x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
    hi, lo = HILO(x)
    fhi = modf(hi)[1]
    flo = modf(lo)[1]
    return Double(E, (fhi, flo))
end

function modf(x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
    hi, lo = HILO(x)
    fhi, ihi = modf(hi)
    flo, ilo = modf(lo)
    i = Double(E, (ihi, ilo))
    f = Double(E, (fhi, flo))
    return f, i
end

function fmod(fpart::Double{T,E}, ipart::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
   return ipart + fpart
end

