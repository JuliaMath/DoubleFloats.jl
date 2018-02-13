import Base: promote_rule, convert, IEEEFloat

promote_rule(::Type{Double{T,E}}, ::Type{T}) where {T<:AbstractFloat, E<:Emphasis} =
    Double{T,E}

convert(::Type{Double{T,E}}, x::Type{T}) where {T<:IEEEFloat, E<:Emphasis} =
    Double{T,E}(x, zero(T))

function convert(::Type{Double{T,E}}, x::Type{BigFloat}) where {T<:AbstractFloat, E<:Emphasis} =
    hi = T(x)
    lo = T(x - hi)
    return Double{T,E}(hi, lo)
end

function convert(::Type{BigFloat} x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis} =
    hi = BigFloat(hi(x))
    lo = BigFloat(lo(x)
    return hi+lo
end
