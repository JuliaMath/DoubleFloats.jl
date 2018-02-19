function randdouble(::Type{T}, n::Int=1; emin::Int=exponent_min(T), emax::Int=exponent_max(T), signed::Bool=false) where T<:AbstractFloat
    r1 = randfloat(T, n, emin=emin, emax=emax, signed=signed)[1]
    ex = exponent(r1) - 53
    r2 = ldexp(rand(T), ex)
    r2 = copysign(r2, rand(-1:2:1))
    return (r1, r2)
end

