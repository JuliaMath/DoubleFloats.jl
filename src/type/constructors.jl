Double{T,E}(x::T) where {T<:Float64, E<:Accuracy} = Double(E, x, 0.0)
Double{T,E}(x::T) where {T<:Float32, E<:Accuracy} = Double(E, x, 0.0f0)
Double{T,E}(x::T) where {T<:Float16, E<:Accuracy} = Double(E, x, zero(Float16))
Double{T,E}(x::T) where {T<:Float64, E<:Performance} = Double(E, x, 0.0)
Double{T,E}(x::T) where {T<:Float32, E<:Performance} = Double(E, x, 0.0f0)
Double{T,E}(x::T) where {T<:Float16, E<:Performance} = Double(E, x, zero(Float16))

Double{T,Accuracy}(x::T) where {T<:Float64} = Double{Float64, Accuracy}(x, 0.0)
Double{T,Performance}(x::T) where {T<:Float64} = Double{Float64, Performance}(x, 0.0)


# Float64 can accomodate any SmallInteger
const SmallInteger = Union{Int8, Int16, Int32, UInt8, UInt16, UInt32}
const LargeInteger = Union{Int64, Int128, UInt64, UInt128}
const BigNumber    = Union{BigInt,BigFloat,Rational{BigInt}}

@inline function big2hilo(::Type{T}, x::B) where {T<:AbstractFloat, B<:BigNumber}
     hi = T(x)
     lo = T(x - B(hi))
     return hi, lo
end

@inline function big2hilo(x::B) where {B<:BigNumber}
     return big2hilo(Float64, x)
end

Double(::Type{E}, hi::T, lo::T) where {T<:SmallInteger, E<:Emphasis} =
    Double(E, (Float64(hi), Float64(lo)))
Double(::Type{E}, hi::T) where {T<:SmallInteger, E<:Emphasis} =
    Double(E, (Float64(hi), zero(Float64)))

# !!TODO!! special case largest values
Double(::Type{E}, hi::T, lo::T) where {T<:LargeInteger, E<:Emphasis} =
    Double(E, (Float64(hi), Float64(lo)))
Double(::Type{E}, hi::T) where {T<:LargeInteger, E<:Emphasis} =
    Double(E, (Float64(hi), zero(Float64)))

function Double(::Type{E}, hi::T, lo::T) where {T<:BigNumber, E<:Emphasis}
    fhi, flo = big2hilo(Float64, hi+lo)
    return Double(E, fhi, flo)
end

function Double(::Type{E}, hi::T) where {T<:BigNumber, E<:Emphasis}
    fhi, flo = big2hilo(Float64, hi)
    return Double(E, fhi, flo)
end


Double{T, Accuracy}(x::T) where {T<:BigFloat} = Double(Accuracy, big2hilo(Float64, x)...,)
Double{T, Performance}(x::T) where {T<:BigFloat} = Double(Performance, big2hilo(Float64, x)...,)
Double(x::BigFloat) where {Float64, Accuracy} = Double(Accuracy, big2hilo(Float64, x)...,)

Double(x::BigFloat) where {Float64, Performance} = Double(Performance, big2hilo(Float64, x)...,)

Double(::Type{Accuracy}, x::B) where {B<:BigNumber} = Double{Float64, Accuracy}(x)
Double(::Type{Performance}, x::B) where {B<:BigNumber} = Double{Float64, Performance}(x)
#=
Double(hi::T) where {T<:BigNumber} = Double(big2hilo(Float64,hi)...,)
Double(hi::T, lo::T) where {T<:BigNumber} = Double(big2hilo(hi+lo)...,)

FastDouble(hi::T) where {T<:BigNumber} = FastDouble(big2hilo(Float64,hi)...,)
FastDouble(hi::T, lo::T) where {T<:BigNumber} = FastDouble(big2hilo(hi+lo)...,)
=#

Double(hi::T) where {T<:IEEEFloat} = Double(Accuracy, hi, zero(T))
Double(hi::T, lo::T) where {T<:IEEEFloat} = Double(Accuracy, (hi, lo))

FastDouble(hi::T) where {T<:IEEEFloat} = Double(Performance, hi, zero(T))
FastDouble(hi::T, lo::T) where {T<:IEEEFloat} = Double(Performance, (hi, lo))

Double(hi::T) where {T<:Integer} = Double(Float64(hi))
Double(hi::T, lo::T) where {T<:Integer} = Double(Float64(hi), Float64(lo))

FastDouble(hi::T) where {T<:Integer} = FastDouble(Float64(hi))
FastDouble(hi::T, lo::T) where {T<:Integer} = FastDouble(Float(hi), Float64(lo))


Double(x::Irrational{S}) where {S} = Double{Float64, Accuracy}(BigFloat(x))
FastDouble(x::Irrational{S}) where {S} = Double{Float64, Performance}(BigFloat(x))

Double{T,Accuracy}(x::Irrational{S}) where {S, T<:AbstractFloat} = Double{T,Accuracy}(BigFloat(x))
Double{T,Performance}(x::Irrational{S}) where {S, T<:AbstractFloat} = Double{T,Performance}(BigFloat(x))

Double{Float64}(x::T) where {T<:AbstractFloat} =Double(Accuracy, (Float64(x), Float64(x-Float64(x))))
Double{Float32}(x::T) where {T<:AbstractFloat} = Double(Accuracy, (Float32(x), Float32(x-Float32(x))))
Double{Float16}(x::T) where {T<:AbstractFloat} = Double(Accuracy, (Float16(x), Float16(x-Float16(x))))

function Double{Float64}(x::T, y::T) where {T<:AbstractFloat}
    xy = x + y
    xx = Float64(xy)
    yy = Float64(xy - xx)
    return Double(Accuracy, (xx, yy))
end
function Double{Float32}(x::T, y::T) where {T<:AbstractFloat}
    xy = x + y
    xx = Float32(xy)
    yy = Float32(xy - xx)
    return Double(Accuracy, (xx, yy))
end
function Double{Float16}(x::T, y::T) where {T<:AbstractFloat}
    xy = x + y
    xx = Float16(xy)
    yy = Float16(xy - xx)
    return Double(Accuracy, (xx, yy))
end

#=
FastDouble{Float64}(x::T) where {T<:AbstractFloat} = 
    Double(Performance, (Float64(x), Float64(x-Float64(x))))
FastDouble{Float32}(x::T) where {T<:AbstractFloat} =
    Double(Performance, (Float32(x), Float32(x-Float32(x))))
FastDouble{Float16}(x::T) where {T<:AbstractFloat} =
    Double(Performance, (Float16(x), Float16(x-Float16(x))))

function FastDouble{Float64}(x::T, y::T) where {T<:AbstractFloat}
    xy = x + y
    xx = Float64(xy)
    yy = Float64(xy - xx)
    return Double(Performance, (xx, yy))
end
function FastDouble{Float32}(x::T, y::T) where {T<:AbstractFloat}
    xy = x + y
    xx = Float32(xy)
    yy = Float32(xy - xx)
    return Double(Performance, (xx, yy))
end
function FastDouble{Float16}(x::T, y::T) where {T<:AbstractFloat}
    xy = x + y
    xx = Float16(xy)
    yy = Float16(xy - xx)
    return Double(Performance, (xx, yy))
end
=#

Float64(x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis} =
    Float64(HI(x)) + Float64(LO(x))
Float32(x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis} =
    Float32(Float64(x))
Float16(x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis} =
    Float16(Float64(x))

Int64(x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis} =
    Int64(Float64(x))
Int32(x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis} =
    Int32(Int64(x))
Int16(x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis} =
    Int16(Int64(x))
Int8(x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis} =
    Int8(Int64(x))

UInt64(x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis} =
    UInt64(Int64(x))
UInt32(x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis} =
    UInt32(UInt64(x))
UInt16(x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis} =
    UInt16(UInt64(x))
UInt8(x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis} =
    UInt8(UInt64(x))

BigFloat(x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis} =
    BigFloat(HI(x)) + BigFloat(LO(x))
BigInt(x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis} =
    BigInt(HI(x)) + BigInt(LO(x))
Rational{BigInt}(x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis} =
    convert(Rational{BigInt}, BigFloat(HI(x)) + BigFloat(LO(x)))
