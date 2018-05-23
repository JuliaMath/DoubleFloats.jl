using Random
import Random.rand

function rand(rng::AbstractRNG, S::Type{DoubleFloat{T}}) where {T<:IEEEFloat}
    u  = rand(rng, UInt64)
    f  = Float64(u)
    uf = UInt64(f)
    ur = uf > u ? uf - u : u - uf
    rf = Float64(ur)

    DoubleFloat(T(5.421010862427522e-20 * f), T(5.421010862427522e-20 * rf))
end

rand(::Type{DoubleFloat{T}}) where {T<:AbstractFloat} =
    rand(Random.GLOBAL_RNG, DoubleFloat{T})

for T in (:Float64, :Float32, :Float16)
  @eval begin
        
    function rand(::Type{DoubleFloat{$T}}, n::Int)
        rs = Array{DoubleFloat{$T}}(undef, n)
        for idx=1:n
            rs[idx] = rand(DoubleFloat{$T})
        end
        return rs
    end
        
  end
end

rand(::Type{DoubleFloat}, n::Int) = rand(DoubleFloat{Float64}, n)
