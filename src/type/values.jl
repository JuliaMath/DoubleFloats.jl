nan(::Type{T}) where T<:AbstractFloat = T(NaN)
inf(::Type{T}) where T<:AbstractFloat = T(Inf)

zero(::Type{Double{T,E}}) where {T<:AbstractFloat,E<:Emphasis} = Double(E, zero(T), zero(T))
zero(::Type{Double{T}}) where {T<:AbstractFloat} = Double(Accuracy, zero(T), zero(T))

one(::Type{Double{T,E}}) where {T<:AbstractFloat,E<:Emphasis} = Double(E, one(T), zero(T))
one(::Type{Double{T}}) where {T<:AbstractFloat} = Double(Accuracy, one(T), zero(T))

nan(::Type{Double{T,E}}) where {T<:AbstractFloat,E<:Emphasis} = Double(E, T(NaN), zero(T))
nan(::Type{Double{T}}) where {T<:AbstractFloat} = Double(Accuracy, T(NaN), zero(T))

inf(::Type{Double{T,E}}) where {T<:AbstractFloat,E<:Emphasis} = Double(E, T(Inf), zero(T))
inf(::Type{Double{T}}) where {T<:AbstractFloat} = Double(Accuracy, T(Inf), zero(T))

function convert(::Type{Double{T,E}}, x::AbstractFloat) where {T<:AbstractFloat,E<:Emphasis}
    isnan(x) && return nan(Double{T,E})
    isinf(x) && return inf(Double{T,E})
    return Double(E, x)
end

typemax(::Type{Double{T,E}}) where {T<:AbstractFloat,E<:Emphasis} = Double(E, typemax(T))
typemin(::Type{Double{T,E}}) where {T<:AbstractFloat,E<:Emphasis} = Double(E, typemin(T))

realmax(::Type{Double{T,E}}) where {T<:AbstractFloat,E<:Emphasis} = Double(E, realmax(T))
realmin(::Type{Double{T,E}}) where {T<:AbstractFloat,E<:Emphasis} = Double(E, realmin(T))

eps(::Type{Double{T,E}}) where {T<:AbstractFloat,E<:Emphasis} = Double(E, eps(eps(T)))
eps(x::Double{T,E}) where {T<:AbstractFloat,E<:Emphasis} = eps(eps(T)) * x
