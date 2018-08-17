using Random
import Random.rand

function rand(rng::AbstractRNG, ::Random.SamplerTrivial{Random.CloseOpen01{DoubleFloat{T}}}) where {T<:IEEEFloat}
    hi, lo  = rand(rng, T, 2)
    frlo, xplo  = frexp(lo)
    xplo = Base.exponent(hi) - min(1, fld(xplo,4)) - abs(Base.exponent(eps(hi)))
    lo = ldexp(frlo, xplo)
    lo = rand(Bool) ? lo : -lo

    DoubleFloat(hi, lo)
end

