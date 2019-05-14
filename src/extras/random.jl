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

function randpm(::Type{DoubleFloat{T}}) where {T<:IEEEFloat}
    r = rand(DoubleFloat{T})
    r = rand(Bool) ? r : -r
    return r
end

function randpm(rng::MersenneTwister, ::Type{DoubleFloat{T}}) where {T<:IEEEFloat}
    r = rand(rng, DoubleFloat{T})
    r = rand(Bool) ? r : -r
    return r
end

function randpm(::Type{Complex{DoubleFloat{T}}}) where {T<:IEEEFloat}
    re = randpm(DoubleFloat{T})
    im = randpm(DoubleFloat{T})
    return Complex{DoubleFloat{T}}(re, im)
end

function randpm(rng::MersenneTwister, ::Type{Complex{DoubleFloat{T}}}) where {T<:IEEEFloat}
    re = randpm(rng, DoubleFloat{T})
    im = randpm(rng, DoubleFloat{T})
    return Complex{DoubleFloat{T}}(re, im)
end

function randpm(::Type{DoubleFloat{T}}, n::Int) where {T<:IEEEFloat}
    rs = rand(DoubleFloat{T}, n)
    sgns = ones(n) .- (2 .* rand(Bool, n))
    return rs .* sgns
end

function randpm(::Type{Complex{DoubleFloat{T}}}, n::Int) where {T<:IEEEFloat}
    res = rand(DoubleFloat{T}, n)
    ims = rand(DoubleFloat{T}, n)
    o = ones(n)
    rsgns = o .- (2 .* rand(Bool,n))
    isgns = o .- (2 .* rand(Bool,n))
    res = res .* rsgns
    ims = ims .* isgns
    return map((re,im)->Complex{DoubleFloat{T}}(re,im), res, ims)
end

function randpm(rng::MersenneTwister, ::Type{DoubleFloat{T}}, n::Int) where {T<:IEEEFloat}
    rs = rand(rng, DoubleFloat{T}, n)
    sgns = ones(n) .- (2 .* rand(rng, Bool, n))
    return rs .* sgns
end

function randpm(rng::MersenneTwister, ::Type{Complex{DoubleFloat{T}}}, n::Int) where {T<:IEEEFloat}
    res = rand(rng, DoubleFloat{T}, n)
    ims = rand(rng, DoubleFloat{T}, n)
    o = ones(n)
    rsgns = o .- (2 .* rand(rng, Bool,n))
    isgns = o .- (2 .* rand(rng, Bool,n))
    res = res .* rsgns
    ims = ims .* isgns
    return map((re,im)->Complex{DoubleFloat{T}}(re,im), res, ims)
end

# normal variates

function randn(rng::AbstractRNG, ::Type{DoubleFloat{T}}) where {T<:IEEEFloat}
    urand1, urand2 = rand(DoubleFloat{T}, 2)
    urand1 = urand1 + urand1 - 1
    urand2 = urand2 + urand2 - 1
    s = urand1*urand1 + urand2*urand2
    
    while s >= 1 || s === 0
        urand1, urand2 = rand(DoubleFloat{T}, 2)
        urand1 = urand1 + urand1 - 1
        urand2 = urand2 + urand2 - 1
        s = urand1*urand1 + urand2*urand2
    end
    
    s = sqrt( -log(s) / s )
    return (urand1 + urand2) * s
end
