tan(x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat} = sin(x) / cos(x)
tanh(x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat} = sinh(x) / cosh(x)
