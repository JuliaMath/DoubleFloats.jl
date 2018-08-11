using Random
import Random.rand

function rand(rng::AbstractRNG, ::Random.SamplerTrivial{Random.CloseOpen01{DoubleFloat{T}}}) where {T<:IEEEFloat}
    u  = rand(rng, UInt64)
    u  = frexp(u)
    f  = Float64(u)
    uf = UInt64(f)
    ur = uf > u ? uf - u : u - uf
    rf = Float64(ur)

    DoubleFloat(T(5.421010862427522e-20 * f), T(5.421010862427522e-20 * rf))
end
