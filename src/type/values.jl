zero(::Type{Double{T,E}}) where {T<:Real,E<:Emphasis} = Double(E, zero(T), zero(T))

one(::Type{Double{T,E}}) where {T<:Real,E<:Emphasis} = Double(E, one(T), zero(T))

nan(::Type{Double{T,E}}) where {T<:Real,E<:Emphasis} = Double(E, T(NaN), zero(T))

inf(::Type{Double{T,E}}) where {T<:Real,E<:Emphasis} = Double(E, T(Inf), zero(T))
