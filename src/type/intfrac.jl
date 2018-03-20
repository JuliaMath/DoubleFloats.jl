@inline function intpart(x::Tuple{T,T}) where {T<:AbstractFloat}
    hi, lo = x
    ihi = modf(hi)[2]
    ilo = modf(lo)[2]
    return ihi, ilo
end

@inline function fracpart(x::Tuple{T,T}) where {T<:AbstractFloat}
    hi, lo = x
    fhi = modf(hi)[1]
    flo = modf(lo)[1]
    return fhi, flo
end


function intpart(x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
    ihi, ilo = intpart(HILO(x))
    return Double(E, (ihi, ilo))
end


function fracpart(x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
    fhi, flo = fracpart(HILO(x))
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

function fmod(parts::Tuple{Double{T,E}, Double{T,E}}) where {T<:AbstractFloat, E<:Emphasis}
   return parts[1] + parts[2]
end

