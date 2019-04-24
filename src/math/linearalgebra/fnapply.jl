
@inline lt_for_sort(a::DoubleFloat{T}, b::DoubleFloat{T}) where {T<:IEEEFloat} = a < b
@inline lt_for_sort(a::Complex{DoubleFloat{T}},b::Complex{DoubleFloat{T}}) where {T<:IEEEFloat} =
    (real(a) < real(b)) || (real(a)==real(b) && imag(a)<imag(b))

function eigenvals(m::Array{DoubleFloat{T},2}) where {T<:IEEEFloat}
    evals = eigvals(m)
    return sort(evals, lt=lt_for_sort)
end

function eigenvals(m::Array{Complex{DoubleFloat{T}},2}) where {T<:IEEEFloat}
    evals = eigvals(m)
    return sort(evals, lt=lt_for_sort)
end

fnapplay(fn, m::Array{DoubleFloat{T},2}) where {T<:IEEEFloat} =
    eigvecs(m) * fn(Diagonal(eigenvals(m))) * inv(eigvecs(m))

fnapplay(fn, m::Array{Complex{DoubleFloat{T}},2}) where {T<:IEEEFloat} =
    eigvecs(m) * fn(Diagonal(eigenvals(m))) * inv(eigvecs(m))

LinearAlgebra.sqrt(m::Array{DoubleFloat{T},2}) where {T<:IEEEFloat} = fnapplay(sqrt, m)
LinearAlgebra.exp(m::Array{DoubleFloat{T},2}) where {T<:IEEEFloat} = real.(fnapplay(exp, m))
LinearAlgebra.log(m::Array{DoubleFloat{T},2}) where {T<:IEEEFloat} = fnapplay(log, m)
LinearAlgebra.sin(m::Array{DoubleFloat{T},2}) where {T<:IEEEFloat} = real.(fnapplay(sin, m))
LinearAlgebra.cos(m::Array{DoubleFloat{T},2}) where {T<:IEEEFloat} = real.(fnapplay(cos, m))
LinearAlgebra.tan(m::Array{DoubleFloat{T},2}) where {T<:IEEEFloat} = real.(fnapplay(tan, m))

Base.:(^)(m::Array{DoubleFloat{T},2}, p::F) where {T<:IEEEFloat, F<:IEEEFloat} = isinteger(p) ? m^Integer(p) : exp(p * log(m))

LinearAlgebra.sqrt(m::Array{Complex{DoubleFloat{T}},2}) where {T<:IEEEFloat} = fnapplay(sqrt, m)
LinearAlgebra.exp(m::Array{Complex{DoubleFloat{T}},2}) where {T<:IEEEFloat} = fnapplay(exp, m)
LinearAlgebra.log(m::Array{Complex{DoubleFloat{T}},2}) where {T<:IEEEFloat} = fnapplay(log, m)
LinearAlgebra.sin(m::Array{Complex{DoubleFloat{T}},2}) where {T<:IEEEFloat} = fnapplay(sin, m)
LinearAlgebra.cos(m::Array{Complex{DoubleFloat{T}},2}) where {T<:IEEEFloat} = fnapplay(cos, m)
LinearAlgebra.tan(m::Array{Complex{DoubleFloat{T}},2}) where {T<:IEEEFloat} = fnapplay(tan, m)

Base.:(^)(m::Array{Complex{DoubleFloat{T}},2}, p::F) where {T<:IEEEFloat, F<:IEEEFloat} = isinteger(p) ? m^Integer(p) : exp(p * log(m))
