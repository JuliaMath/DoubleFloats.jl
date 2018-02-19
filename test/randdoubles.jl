function randdouble(::Type{T}, n::Int=1; emin::Int=exponent_min(T), emax::Int=exponent_max(T), signed::Bool=false) where T<:AbstractFloat
    r1 = randfloat(T, n, emin=emin, emax=emax, signed=signed)[1]
    ex = exponent(r1) - 53
    r2 = randfloat(T,n , emin = emin-53, emax = ex-53, signed=signed)[1]
    r2 = ldexp(frexp(r2)[1], ex)
    return (r1, r2)
end

