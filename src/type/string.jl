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
    prec = precision(Base.BigFloat)
    setprecision(Base.BigFloat, BigFloatBits(T))
    bf = Base.BigFloat(x)
    bf = round(bf, digits=BigFloatDigits(T)) + HI(eps(x))
    str = string(bf)
    if occursin('e', str)
       a, b = split(str, "e")
       str = string(a[1:BigFloatDigits(T)+1],"e",b)
    else
       str = str[1:BigFloatDigits(T)+1]
    end
    setprecision(Base.BigFloat, prec)
    return str
end

function string(x::DoubleFloat{DoubleFloat{T}}) where {T<:IEEEFloat}
    prec = precision(Base.BigFloat)
    setprecision(Base.BigFloat, BigFloatBits(T)*2)
    bf = Base.BigFloat(x)
    bf = round(bf, digits=BigFloatDigits(T)*2) + HI(eps(LO(x)))
    str = string(bf)
    if occursin('e', str)
       a, b = split(str, "e")
       str = string(a[1:(BigFloatDigits(T)*2+1)],"e",b)
    else
       str = str[1:(BigFloatDigits(T)*2+1)]
    end
    setprecision(Base.BigFloat, prec)
    return str
end
