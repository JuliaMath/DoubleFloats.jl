erf(x::Double64) = Double64Float128(erf, x)
erfc(x::Double64) = Double64Float128(erfc, x)
gamma(x::Double64) = Double64Float128(gamma, x)
lgamma(x::Double64) = Double64Float128(lgamma, x)

erf(x::Double32) = Double32Float128(erf, x)
erfc(x::Double32) = Double32Float128(erfc, x)
gamma(x::Double32) = Double32Float128(gamma, x)
lgamma(x::Double32) = Double32Float128(lgamma, x)

erf(x::Double16) = Double16Float128(erf, x)
erfc(x::Double16) = Double16Float128(erfc, x)
gamma(x::Double16) = Double16Float128(gamma, x)
lgamma(x::Double16) = Double16Float128(lgamma, x)

function logabsgamma(x::DoubleFloat{T}) where {T<:IEEEFloat}
    sign = x >= 0 ? 1 : 2*mod(ceil(Int64,x),2)-1
    return lgamma(x), sign
end
