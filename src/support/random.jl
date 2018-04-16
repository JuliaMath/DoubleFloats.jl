using Random
import Random.rand

function rand(rng::AbstractRNG, S::Type{Double{T,E}}) where {T<:AbstractFloat, E<:Emphasis}
    u  = rand(rng, UInt64)
    f  = Float64(u)
    uf = UInt64(f)
    ur = uf > u ? uf - u : u - uf
    rf = Float64(ur)

    Double(E, T(5.421010862427522e-20 * f), T(5.421010862427522e-20 * rf))
end

rand(::Type{Double{T,E}}) where {T<:AbstractFloat, E<:Emphasis} =
    rand(Random.GLOBAL_RNG, Double{T,E})

rand(::Type{Double}) = rand(Double{Float64, Accuracy})
rand(x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis} = rand(Double{T,E})

rand(x::Function) = (x == FastDouble) ?
                    rand(Double{Float64,Performance}) :
                    throw(DomainError(string(x)))

rand(::Type{Double}, n::Int) = [rand(Double) for i=1:n]

rand(x::Function, n::Int) = (x == FastDouble) ?
                    [rand(Double{Float64,Performance}) for i=1:n] :
                    throw(DomainError(string(x)))
