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

for T in (:Float64, :Float32, :Float16)
  @eval begin
        
    function rand(::Type{Double{$T,Accuracy}}, n::Int)
        rs = Array{Double{$T,Accuracy}}(undef, n)
        for idx=1:n
            rs[idx] = rand(Double{$T,Accuracy})
        end
        return rs
    end

    function rand(::Type{Double{$T,Performance}}, n::Int)
        rs = Array{Double{$T,Performance}}(undef, n)
        for idx=1:n
            rs[idx] = rand(Double{$T,Performance})
        end
        return rs
    end
        
  end
end

rand(::Type{Double}, n::Int) = rand(Double{Float64, Accuracy}, n)

rand(x::Function, n::Int) = (x == FastDouble) ?
                    rand(Double{Float64,Performance}, n) :
                    throw(DomainError(string(x)))
