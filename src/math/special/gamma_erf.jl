erf(x::Double64) = Double64Float128(erf, x)
erfc(x::Double64) = Double64Float128(erfc, x)
gamma(x::Double64) = Double64Float128(gamma, x)
lgamma(x::Double64) = Double64Float128(lgamma, x)
loggamma(x::Double64) = Double64Float128(lgamma, x)

erf(x::Double32) = Double32Float128(erf, x)
erfc(x::Double32) = Double32Float128(erfc, x)
gamma(x::Double32) = Double32Float128(gamma, x)
lgamma(x::Double32) = Double32Float128(lgamma, x)
loggamma(x::Double32) = Double32Float128(lgamma, x)

erf(x::Double16) = Double16Float128(erf, x)
erfc(x::Double16) = Double16Float128(erfc, x)
gamma(x::Double16) = Double16Float128(gamma, x)
lgamma(x::Double16) = Double16Float128(lgamma, x)
loggamma(x::Double16) = Double16Float128(lgamma, x)

function logabsgamma(x::DoubleFloat{T}) where {T<:IEEEFloat}
    keep_precision = precision(BigFloat)
    setprecision(BigFloat, 128)
    result = logabsgamma(BigFloat(x))
    setprecision(BigFloat, keep_precision)
    return DoubleFloat{T}(result[1]), result[2]
end
