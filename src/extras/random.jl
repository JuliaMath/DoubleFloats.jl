function rand(rng::AbstractRNG, ::Random.SamplerTrivial{Random.CloseOpen01{DoubleFloat{T}}}) where {T<:IEEEFloat}
    hi, lo  = rand(rng, T, 2)
    if hi === zero(T)
        if lo === zero(T)
            return zero(DoubleFloat(T))
        end
        hi, lo = lo, hi
    end
    frlo, xplo  = frexp(lo)
    xplo = Base.exponent(hi) - min(1, fld(xplo,4)) - abs(Base.exponent(eps(hi)))
    lo = ldexp(frlo, xplo)
    lo = rand(Bool) ? lo : -lo

    DoubleFloat(hi, lo)
end

function rand(rng::AbstractRNG, ::Random.SamplerTrivial{Random.CloseOpen01{Complex{DoubleFloat{T}}}}) where {T<:IEEEFloat}
    re = rand(DoubleFloat{T})
    im = rand(DoubleFloat{T})
    return Complex{DoubleFloat{T}}(re, im)
end

