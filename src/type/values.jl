zero(::Type{Double{T,E}}) where {T<:AbstractFloat,E<:Emphasis} = Double(E, zero(T), zero(T))
zero(::Type{Double{T}}) where {T<:AbstractFloat} = Double(Accuracy, zero(T), zero(t))

one(::Type{Double{T,E}}) where {T<:AbstractFloat,E<:Emphasis} = Double(E, one(T), zero(T))
one(::Type{Double{T}}) where {T<:AbstractFloat} = Double(Accuracy, one(T), zero(t))

nan(::Type{Double{T,E}}) where {T<:AbstractFloat,E<:Emphasis} = Double(E, T(NaN), zero(T))
nan(::Type{Double{T}}) where {T<:AbstractFloat} = Double(Accuracy, T(NaN), zero(t))

inf(::Type{Double{T,E}}) where {T<:AbstractFloat,E<:Emphasis} = Double(E, T(Inf), zero(T))
inf(::Type{Double{T}}) where {T<:AbstractFloat} = Double(Accuracy, T(Inf), zero(t))
