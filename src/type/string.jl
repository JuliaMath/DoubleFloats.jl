function stringtyped(x::Double64)
    str = string("Double64(", HI(x), ", ", LO(x), ")")
    return str
end
function stringtyped(x::Double32)
    str = string("Double32(", HI(x), ", ", LO(x), ")")
    return str
end
function stringtyped(x::Double16)
    str = string("Double16(", HI(x), ", ", LO(x), ")")
    return str
end

@inline BigFloatBits(::Type{Float64}) = 512
@inline BigFloatBits(::Type{Float32}) = 256
@inline BigFloatBits(::Type{Float16}) = 128
@inline BigFloatDigits(::Type{Float64}) = 35
@inline BigFloatDigits(::Type{Float32}) = 18
@inline BigFloatDigits(::Type{Float16}) =  9

function string(x::DoubleFloat{T}) where {T<:IEEEFloat}
    !isfinite(HI(x)) && return string(HI(x))
    prec = precision(Base.BigFloat)
    setprecision(Base.BigFloat, BigFloatBits(T))
    bf = Base.BigFloat(x)
    bf = round(bf, digits=BigFloatBits(T), base=2)
    str = string(bf)
    if occursin('e', str)
       a, b = split(str, "e")
       n = min(length(a), BigFloatDigits(T)+1)
       str = string(a[1:n],"e",b)
    else
       n = min(length(str), BigFloatDigits(T)+1)
       str = str[1:n]
    end
    setprecision(Base.BigFloat, prec)
    return str
end
