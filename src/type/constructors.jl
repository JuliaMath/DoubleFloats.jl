#=
    initializers

    Double(Emphasis, hi, lo) constructs immediately

    Double(Emphasis, (hi, lo)) fully normalizes before construction

    Double((hi, lo), Emphasis) renormalizes, requires (|hi|>=|lo|)

    Double{T,E}(hi, lo) constructs immediately, (better to use above)

=#

# these bypass the renormalization

Double(::Type{Accuracy}, hi::T, lo::T) where {T<:AbstractFloat} =
    Double{T,Accuracy}(hi, lo)
Double(::Type{Performance}, hi::T, lo::T) where {T<:AbstractFloat} =
    Double{T,Performance}(hi, lo)
Double(::Type{Accuracy}, hi::T) where {T<:AbstractFloat} =
    Double{T,Accuracy}(hi, zero(T))
Double(::Type{Performance}, hi::T) where {T<:AbstractFloat} =
    Double{T,Performance}(hi, zero(T))

#these always normalize

function Double(::Type{E}, hilo::Tuple{T, T}) where {T<:AbstractFloat, E<:Emphasis}
    hi, lo = hilo
    hi, lo = add_2(hi, lo)
    return Double(E, hi, lo)
end
function Double(::Type{E}, hilo::Tuple{T}) where {T<:AbstractFloat, E<:Emphasis}
    return Double(E, hi, zero(T))
end

# Float64 can accomodate any SmallInteger
const SmallInteger = Union{Int8, Int16, Int32, UInt8, UInt16, UInt32}
const LargeInteger = Union{Int64, Int128, UInt64, UInt128}
const BigNumber    = Union{BigInt,BigFloat,Rational{BigInt}}

@inline function big2hilo(::Type{T}, x::B) where {T<:AbstractFloat, B<:BigNumber}
     hi = T(x)
     lo = T(x - hi)
     return hi, lo
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

#=
Double(::Type{E}, hi::T, lo::T) where {T<:Union{Int8,Int16,Int32,Int8,Int16,Int32}, E<:Emphasis} =
    Double(E, (Float64(hi), Float64(lo)))

Double(::Type{Performance}, hi::T, lo::T) where {T<:AbstractFloat} =
    Double{T,Performance}(hi, lo)
Double(::Type{Accuracy}, hi::T) where {T<:AbstractFloat} =
    Double{T,Accuracy}(hi, zero(T))
Double(::Type{Performance}, hi::T) where {T<:AbstractFloat} =
    Double{T,Performance}(hi, zero(T))
=#
#=
function Double(::Type{Performance}, hilo::Tuple{T, T}) where {T<:AbstractFloat} 
    hi, lo = hilo
    hi, lo = add_2(hi, lo)
    return Double(Performance, hi, lo)
end
=#

#these always renormalize, require abs(hi)>=abs(lo) !!UNCHECKED!!

function Double(hilo::Tuple{T, T}, ::Type{E}) where {T<:AbstractFloat, E<:Emphasis}
    hi, lo = hilo
    hi, lo = add_hilo_2(hi, lo)
    return Double(Accuracy, hi, lo)
end
#=
function Double(hilo::Tuple{T, T}, ::Type{Performance}) where {T<:AbstractFloat}
    hi, lo = hilo
    hi, lo = add_hilo_2(hi, lo)
    return Double(Performance, hi, lo)
end
=#

Double(hi::T) where {T<:IEEEFloat} = 
    Double(Accuracy, hi, zero(T))

#=
Double(hi::T) where {T<:Rea} = 
    Double(Accuracy, Float64(hi), zero(Float64))

Double(hi::T) where {T<:AbstractFloat} = 
    Double(Accuracy, (hi, zero(T)))
Double(hi::T, lo::T) where {T<:AbstractFloat} =
    Double(Accuracy, (hi, lo))

FastDouble(hi::T) where {T<:AbstractFloat} = 
    Double(Performance, Float64(hi), zero(T))
FastDouble(hi::T, lo::T) where {T<:AbstractFloat} =
    Double(Performance, (hi, lo))

Double{T}(hi) where {T<:IEEEFloat} = 
    Double(Accuracy, T(hi), zero(T))
Double{T}(hi, lo) where {T<:AbstractFloat} =
    Double(Accuracy,(T(hi+lo), T(hi+lo-T(hi+lo))))
FastDouble{T}(hi) where {T<:IEEEFloat} = 
    Double(Performance, T(hi), zero(T))
FastDouble{T}(hi, lo) where {T<:AbstractFloat} =
    Double(Performance,(T(hi+lo), T(hi+lo-T(hi+lo))))

=#






#=

@inline function bigfloat2hilo(::Type{T}, x::R) where {T<:AbstractFloat, R<:Real}
     y = BigFloat(x)
     hi = T(y)
     lo = T(y - hi)
     return hi, lo
end

Double(x::BigFloat) = Double(Accuracy, bigfloat2hilo(Float64, x)...,)
FastDouble(x::BigFloat) = Double(Performance, bigfloat2hilo(Float64, x)...,)
Double{T}(x::BigFloat) where {T<:AbstractFloat} = Double(Accuracy, bigfloat2hilo(T, x)...,)
FastDouble{T}(x::BigFloat) where {T<:AbstractFloat} = Double(Performance, bigfloat2hilo(T, x)...,)

Double(x::BigInt) = Double(Accuracy, bigfloat2hilo(Float64, BigFloat(x))...,)
FastDouble(x::BigInt) = Double(Performance, bigfloat2hilo(Float64, BigFloat(x))...,)
Double{T}(x::BigInt) where {T<:AbstractFloat} = Double(Accuracy, bigfloat2hilo(T, BigFloat(x))...,)
FastDouble{T}(x::BigInt) where {T<:AbstractFloat} = Double(Performance, bigfloat2hilo(T, BigFloat(x))...,)

function Double(hi::T) where {T<:Real}
    bf = BigFloat(hi)
    hi, lo = bigfloat2hilo(Float64, bf)
    return Double(Accuracy, hi, lo)
end
function Double(hi::T, lo::T) where {T<:Real}
    bf = BigFloat(hi) + BigFloat(lo)
    hi, lo = bigfloat2hilo(Float64, bf)
    return Double(Accuracy, hi, lo)
end

function FastDouble(hi::T) where {T<:Real}
    bf = BigFloat(hi)
    hi, lo = bigfloat2hilo(Float64, bf)
    return Double(Performance, hi, lo)
end
function FastDouble(hi::T, lo::T) where {T<:Real}
    bf = BigFloat(hi) + BigFloat(lo)
    hi, lo = bigfloat2hilo(Float64, bf)
    return Double(Performance, hi, lo)
end




@inline Double{T, E}(hilo::Tuple{T, T}) where {T<:AbstractFloat, E<:Emphasis} =
    Double{T, E}(hilo[1], hilo[2])

@inline Double(hilo::Tuple{T, T}) where {T<:AbstractFloat} =
    Double{T, Accuracy}(hilo[1], hilo[2])

@inline FastDouble(hilo::Tuple{T, T}) where {T<:AbstractFloat} =
    Double{T, Performance}(hilo[1], hilo[2])


for T in (:Float64, :Float32, :Float16)
  @eval begin
    $T(x::Double{$T, E}) where E<:Emphasis = HI(x)
  end
end
Float32(x::Double{Float64, E}) where E<:Emphasis = Float32(HI(x))
Float16(x::Double{Float64, E}) where E<:Emphasis = Float16(HI(x))
Float16(x::Double{Float32, E}) where E<:Emphasis = Float16(HI(x))

function BigFloat(x::Double{T, E}, p=precision(BigFloat)) where {T<:AbstractFloat, E<:Emphasis}
    BigFloat(HI(x), p) + BigFloat(LO(x), p)
end

=#
