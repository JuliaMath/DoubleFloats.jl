promote_type(::Type{Double{T, Accuracy}}, ::Type{Double{T, Performance}}) where {T<:AbstractFloat} =
    Double{T, Accuracy}

promote_type(::Type{Double{T, Performance}}, ::Type{Double{T, Accuracy}}) where {T<:AbstractFloat} =
    Double{T, Accuracy}

promote_rule(::Type{Double{T, Accuracy}}, ::Type{Double{T, Performance}}) where {T<:AbstractFloat} =
    Double{T, Accuracy}

convert(::Type{Double{T, Accuracy}}, x::Double{T, Performance}) where {T<:AbstractFloat} = Double(Accuracy, HILO(x))

convert(::Type{Double{T, Accuracy}}, x::Double{T, Accuracy}) where {T<:AbstractFloat} = x
convert(::Type{Double{T, Performance}}, x::Double{T, Performance}) where {T<:AbstractFloat} = x

promote_rule(::Type{Double{T,E}}, ::Type{T}) where {T<:AbstractFloat, E<:Emphasis} =
    Double{T,E}

convert(::Type{Double{T,E}}, x::T) where {T<:IEEEFloat, E<:Emphasis} =
    Double{T,E}(x, zero(T))

promote_rule(::Type{Double{T,E}}, ::Type{I}) where {I<:Integer, T<:AbstractFloat, E<:Emphasis} =
    Double{T,E}

convert(::Type{Double{T,E}}, x::I) where {I<:Integer, T<:AbstractFloat, E<:Emphasis} =
    convert(Double{T,E}, float(x))

Double{Float16, E}(x::AbstractFloat) where {E<:Emphasis} = Double(E, Float16(x))
Double{Float32, E}(x::AbstractFloat) where {E<:Emphasis} = Double(E, Float32(x))
Double{Float64, E}(x::AbstractFloat) where {E<:Emphasis} = Double(E, Float64(x))

promote_rule(::Type{Double{T,E}}, ::Type{F}) where {F<:AbstractFloat, T<:AbstractFloat, E<:Emphasis} =
    Double{T,E}

convert(::Type{Double{T,E}}, x::F) where {F<:AbstractFloat, T<:AbstractFloat, E<:Emphasis} =
    Double(E, T(x))

promote_rule(::Type{Double{T,E}}, ::Type{BigFloat}) where {T<:AbstractFloat, E<:Emphasis} =
    Double{T,E}

function convert(::Type{Double{T,E}}, x::BigFloat) where {T<:AbstractFloat, E<:Emphasis}
    hi = T(x)
    lo = T(x - hi)
    return Double{T,E}(hi, lo)
end

function convert(::Type{BigFloat}, x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
    hi = BigFloat(HI(x))
    lo = BigFloat(LO(x))
    return hi+lo
end

promote_rule(::Type{Double{T,E}}, ::Type{BigInt}) where {T<:AbstractFloat, E<:Emphasis} =
    Double{T,E}

function convert(::Type{Double{T,E}}, x::BigInt) where {T<:AbstractFloat, E<:Emphasis}
    return Double{T,E}(BigFloat(x))
end

function convert(::Type{BigInt}, x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
    hi = BigInt(HI(x))
    lo = BigInt(LO(x))
    return hi+lo
end

promote_rule(::Type{Double{T,E}}, ::Type{Rational{I}}) where {I<:Signed, T<:AbstractFloat, E<:Emphasis} =
    Double{T,E}

function convert(::Type{Double{T,E}}, x::Rational{I}) where {I<:Signed, T<:AbstractFloat, E<:Emphasis}
    numer = Double{T,E}(numerator(x))
    denom = Double{T,E}(denominator(x))
    return numer/denom
end

promote_rule(::Type{Double}, ::Type{T}) where {T<:Signed} = Double
promote_rule(::Type{Double}, ::Type{T}) where {T<:AbstractFloat} = Double
