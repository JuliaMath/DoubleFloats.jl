SpecialFunctions.erf(x::Double64) = Double64Float128(erf, x)
SpecialFunctions.erfc(x::Double64) = Double64Float128(erfc, x)
SpecialFunctions.gamma(x::Double64) = Double64Float128(gamma, x)

SpecialFunctions.erf(x::Double32) = Double32Float128(erf, x)
SpecialFunctions.erfc(x::Double32) = Double32Float128(erfc, x)
SpecialFunctions.gamma(x::Double32) = Double32Float128(gamma, x)

SpecialFunctions.erf(x::Double16) = Double16Float128(erf, x)
SpecialFunctions.erfc(x::Double16) = Double16Float128(erfc, x)
SpecialFunctions.gamma(x::Double16) = Double16Float128(gamma, x)

function SpecialFunctions.logabsgamma(x::DoubleFloat{T}) where {T<:IEEEFloat}
    result = logabsgamma(Float128(x))
    return DoubleFloat{T}(result[1]), result[2]
end
