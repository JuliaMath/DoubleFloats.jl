function typedstring(x::DoubleF64)
    str = string("DoubleF64(", HI(x), ", ", LO(x), ")")
    return str
end
function typedstring(x::DoubleF32)
    str = string("DoubleF32(", HI(x), ", ", LO(x), ")")
    return str
end
function typedstring(x::DoubleF16)
    str = string("DoubleF16(", HI(x), ", ", LO(x), ")")
    return str
end
function typedstring(x::QuadrupleF64)
    str = string("QuadrupleF64(", HI(HI(x)), ", ", LO(HI(x)), ", ", HI(LO(x)), ", ", LO(LO(x)),")")
    return str
end
function typedstring(x::QuadrupleF32)
    str = string("QuadrupleF32(", HI(HI(x)), ", ", LO(HI(x)), ", ", HI(LO(x)), ", ", LO(LO(x)),")")
    return str
end
function typedstring(x::QuadrupleF16)
    str = string("QuadrupleF16(", HI(HI(x)), ", ", LO(HI(x)), ", ", HI(LO(x)), ", ", LO(LO(x)),")")
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
    bf = round(bf, digits=BigFloatDigits(T))
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

function string(x::DoubleFloat{DoubleFloat{T}}) where {T<:IEEEFloat}
    !isfinite(HI(HI(x))) && return string(HI(HI(x)))
    prec = precision(Base.BigFloat)
    setprecision(Base.BigFloat, BigFloatBits(T)*2)
    bf = Base.BigFloat(x)
    bf = round(bf, digits=BigFloatDigits(T)*2))
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
