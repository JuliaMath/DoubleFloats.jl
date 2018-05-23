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


function string(x::DoubleFloat{T}) where {T<:IEEEFloat}
    prec = precision(Base.BigFloat)
    setprecision(Base.BigFloat, 512)
    bf = Base.BigFloat(x)
    bf = round(bf, digits=35) + HI(eps(x))
    str = string(bf)
    if occursin('e', str)
       a, b = split(str, "e")
       str = string(a[1:36],"e",b)
    else
       str = str[1:36]
    end
    setprecision(Base.BigFloat, prec)
    return str
end

function string(x::DoubleFloat{DoubleFloat{T}}) where {T<:IEEEFloat}
    prec = precision(Base.BigFloat)
    setprecision(Base.BigFloat, 512)
    bf = Base.BigFloat(x)
    bf = round(bf, digits=70) + HI(eps(LO(x)))
    str = string(bf)
    if occursin('e', str)
       a, b = split(str, "e")
       str = string(a[1:71],"e",b)
    else
       str = str[1:71]
    end
    setprecision(Base.BigFloat, prec)
    return str
end
