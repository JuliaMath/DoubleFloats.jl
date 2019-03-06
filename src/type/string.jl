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

function stringtyped(x::Complex{DoubleFloat{Float64}})
    rea, ima = reim(x)
    str = string("ComplexDF64(", stringtyped(rea), ", ", stringtyped(imag(x)), ")")
    return str
end
function stringtyped(x::Complex{DoubleFloat{Float32}})
    rea, ima = reim(x)
    str = string("ComplexDF32(", stringtyped(rea), ", ", stringtyped(imag(x)), ")")
    return str
end
function stringtyped(x::Complex{DoubleFloat{Float16}})
    rea, ima = reim(x)
    str = string("ComplexDF16(", stringtyped(rea), ", ", stringtyped(imag(x)), ")")
    return str
end

"""
    BigFloatBits(::IEEEType)

significand bit precision for BigFloat when converting from DoubleFloat{IEEEType} into a string
""" BigFloatBits

"""
    BigFloatDigits(::IEEEType)

significant digits of BigFloat when converting to DoubleFloat{IEEEType} from a string
""" BigFloatDigits

# Float63 -> 106, Float32 -> 48, Float16 -> 22
minprecdblfloat(::Type{T}) where {T<:IEEEFloat} = 
    (trailing_ones(Base.significand_mask(T))+1)*2


#=
  The effective precision of some DoubleFloat{T} may be larger than this
     where all bits betweeen the lsb of the HI oart and Lthe msb of the lo part
     are 0b0 and there are more than 22 zero bits interposed for eg Double64.
  When a DoubleFloat is the result of an arithmetic operation between DoubleFloats,
     the effective precision is almost never expected be larger than this.
=#
# Float63 -> 128, Float32 -> 58, Float16 -> 27
lrgprecdblfloat(::Type{T}) where {T<:IEEEFloat} = 
    Int(ceil(Int, minprecdblfloat(T) * 1.2))

bigfloatbits(::Type{T}) where {T<:IEEEFloat} =
    nextpow(2, (trailing_ones(Base.significand_mask(T))+1)*2) - 1

BigFloatBits(::Type{Float64}) = 127 # bigfloatbits(Float64)
BigFloatBits(::Type{Float32}) =  63 # bigfloatbits(Float32)
BigFloatBits(::Type{Float16}) =  31 # bigfloatbits(Float16)

BigFloatDigits(::Type{Float64}) = 35 # bigfloatbits(Float64)
BigFloatDigits(::Type{Float32}) = 16 # bigfloatbits(Float32)
BigFloatDigits(::Type{Float16}) =  8 # bigfloatbits(Float16)

#= old
@inline BigFloatBits(::Type{Float64}) = 512
@inline BigFloatBits(::Type{Float32}) = 256
@inline BigFloatBits(::Type{Float16}) = 128
@inline BigFloatDigits(::Type{Float64}) = 35
@inline BigFloatDigits(::Type{Float32}) = 18
@inline BigFloatDigits(::Type{Float16}) =  9
=#

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

function string(x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat}
    rea, ima = reim(x)
    s = signbit(ima) ? " - " : " + "
    imstr = isfinite(ima) ? "im" : "*im"
    str = string(string(rea), s, string(abs(ima)), imstr)
    return str
end
