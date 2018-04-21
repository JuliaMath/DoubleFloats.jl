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

function rand(::Type{Double{Float64,Accuracy}, n::Int)
    rs = Array{Double{Float64,Accuracy}}(undef, n)
    for idx=1:n
        rs[idx] = rand(Double{Float64,Accuracy})
    end
    return rs
end

function rand(::Type{Double{Float64,Performance}, n::Int)
    rs = Array{Double{Float64,Performance}}(undef, n)
    for idx=1:n
        rs[idx] = rand(Double{Float64,Performance})
    end
    return rs
end

rand(x::Function, n::Int) = (x == FastDouble) ?
                    rand(Double{Float64,Performance}, n) :
                    throw(DomainError(string(x)))
