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

#these always normalize

function Double(::Type{Accuracy}, hilo::Tuple{T, T}) where {T<:AbstractFloat}
    hi, lo = hilo
    hi, lo = add_2(hi, lo)
    return Double(Accuracy, hi, lo)
end
function Double(::Type{Performance}, hilo::Tuple{T, T}) where {T<:AbstractFloat} 
    hi, lo = hilo
    hi, lo = add_2(hi, lo)
    return Double(Performance, hi, lo)
end

#these always renormalize, require abs(hi)>=abs(lo) !!UNCHECKED!!

function Double(hilo::Tuple{T, T}, ::Type{Accuracy}) where {T<:AbstractFloat}
    hi, lo = hilo
    hi, lo = add_hilo_2(hi, lo)
    return Double(Accuracy, hi, lo)
end
function Double(hilo::Tuple{T, T}, ::Type{Performance}) where {T<:AbstractFloat}
    hi, lo = hilo
    hi, lo = add_hilo_2(hi, lo)
    return Double(Performance, hi, lo)
end

Double(hi::T) where {T<:AbstractFloat} = 
    Double(Accuracy, hi, zero(T))
Double(hi::T, lo::T) where {T<:AbstractFloat} =
    Double(Accuracy, hi, lo)

FastDouble(hi::T) where {T<:AbstractFloat} =
    Double(Performance, hi, zero(T))
FastDouble(hi::T, lo::T) where {T<:AbstractFloat} =
    Double(Performance, hi, lo)
 
@inline function bigfloat2hilo(::Type{T}, x::BigFloat) where T<:AbstractFloat
     hi = T(x)
     lo = T(x - hi)
     return hi, lo
end

@inline function bigfloat2hilo(::Type{T}, x::T) where T<:Real
     y = BigFloat(x)
     hi = T(y)
     lo = T(y - hi)
     return hi, lo
end

function Double(hi::T) where {T<:Real}
    bf = BigFloat(hi)
    hi, lo = bigfloat2hilo(T, bf)
    return Double(Accuracy, hi, lo)
end
function Double(hi::T, lo::T) where {T<:Real}
    bf = BigFloat(hi) + BigFloat(lo)
    hi, lo = bigfloat2hilo(T, bf)
    return Double(Accuracy, hi, lo)
end

function FastDouble(hi::T) where {T<:Real}
    bf = BigFloat(hi)
    hi, lo = bigfloat2hilo(T, bf)
    return Double(Performance, hi, lo)
end
function FastDouble(hi::T, lo::T) where {T<:Real}
    bf = BigFloat(hi) + BigFloat(lo)
    hi, lo = bigfloat2hilo(T, bf)
    return Double(Performance, hi, lo)
end


     
#=

zero(::Type{Double{T,E}}) where {T<:AbstractFloat, E<:Emphasis} =
    Double(E, zero(T), zero(T))
one(::Type{Double{T,E}}) where {T<:AbstractFloat, E<:Emphasis} =
    Double(E, one(T), zero(T))
inf(::Type{Double{T,E}}) where {T<:AbstractFloat, E<:Emphasis} =
    Double(E, T(Inf), zero(T))
nan(::Type{Double{T,E}}) where {T<:AbstractFloat, E<:Emphasis} =
    Double(E, T(NaN), zero(T))


intmax(::Type{Float64}) = 2^precision(Float64)
intmax(::Type{Float32}) = 2^precision(Float32)
intmax(::Type{Float16}) = 2^precision(Float16)
intmax2(::Type{Float64}) = Int128(2)^((2*precision(Float64))>>1)
intmax2(::Type{Float32}) = Int128(2)^((2*precision(Float32))>>1)
intmax2(::Type{Float16}) = Int128(2)^((2*precision(Float16))>>1)
 
# sizeof(IEEEInt) <= sizeof(Float64)
const IEEEInt = Union{Int64, Int32, Int16, Int8}
const SmallInt = Union{Int32, Int16, Int8}

Double() = Double{Float64, Accuracy}(zero(Float64), zero(Float64))
FastDouble() = Double{Float64, Performance}(zero(Float64), zero(Float64))

Double{T, E}(x::T) where {T<:IEEEFloat, E<:Emphasis} = Double{T, E}(x, zero(T))

Double(x::T) where {T<:IEEEFloat} = Double{T, Accuracy}(x, zero(T))
FastDouble(x::T) where {T<:IEEEFloat} = Double{T, Performance}(x, zero(T))

Double(x::T) where {T<:SmallInt} =
    Double{T, Accuracy}(Float64(x), zero(Float64))
FastDouble(x::T) where {T<:SmallInt} =
    Double{T, Performance}(Float64(x), zero(Float64))

function Double(x::T) where {T<:Signed}
    if abs(x) <= intmax(Float64)
       hi = Float64(x)
       lo = zero(Float64)
    elseif abs(x) <= intmax2(Float64)
       bf = BigFloat(x)
       hi = Float64(bf)
       lo = Float64(bf-hi)
    else
       throw(DomainError("$x"))
    end
    Double{Float64, Accuracy}(hi, lo)
end

function FastDouble(x::T) where {T<:Signed}
    if abs(x) <= intmax(Float64)
       hi = Float64(x)
       lo = zero(Float64)
    elseif abs(x) <= intmax2(Float64)
       bf = BigFloat(x)
       hi = Float64(bf)
       lo = Float64(bf-hi)
    else
       throw(DomainError("$x"))
    end
    Double{Float64, Performance}(hi, lo)
end

function Double(x::BigFloat)
    if abs(x) <= intmax2(Float64)
        hi = Float64(x)
        lo = Float64(x-hi)
    else
       throw(DomainError("$x"))
    end
    Double{Float64, Accuracy}(hi, lo)
end

function FastDouble(x::BigFloat)
    if abs(x) <= intmax2(Float64)
        hi = Float64(x)
        lo = Float64(x-hi)
    else
       throw(DomainError("$x"))
    end
    Double{Float64, Performance}(hi, lo)
end

Double(x::BigInt) = Double(BigFloat(x))
FastDouble(x::BigInt) = FastDouble(BigFloat(x))
=#


#=
Double(::Type{Accuracy}) = Double{Float64, Accuracy}(zero(Float64), zero(Float64))
Double(::Type{Performance}) = Double{Float64, Performance}(zero(Float64), zero(Float64))
Double(::Type{Accuracy}, hi::T) where {T<:AbstractFloat} = Double{T, Accuracy}(hi, zero(T))
Double(::Type{Performance}, hi::T) where {T<:AbstractFloat} = Double{T, Performance}(hi, zero(T))
Double(::Type{Accuracy}, hi::T, lo::T) where {T<:AbstractFloat} = Double{T, Accuracy}(hi, lo)
Double(::Type{Performance}, hi::T, lo::T) where {T<:AbstractFloat} = Double{T, Performance}(hi, lo)

Double(x::T) where {T<:IEEEFloat} = Double{T, Accuracy}(x, zero(Float64))
Double(x::T) where {T<:Union{Int16, Int32, Int64}} = Double(Accuracy, Float64(x))

FastDouble(x::T) where {T<:IEEEFloat} = Double{T, Performance}(x, zero(Float64))
FastDouble(x::T) where {T<:Union{Int16, Int32, Int64}} = Double(Performance, Float64(x))
=#

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

#=
function Double{T, E}(x::BigFloat) where {T<:AbstractFloat, E<:Emphasis}
    hi = T(x)
    lo = T(x-hi)
    return Double{T, E}(hi, lo)
end

function Double{T, E}(x::BigInt) where {T<:AbstractFloat, E<:Emphasis}
    return Double{T, E}(BigFloat(x))
end

function Double{T,E}(x::Irrational{S}) where {S, T<:AbstractFloat, E<:Emphasis}
    y = BigFloat(x)
    return Double{T,E}(y)
end

function Double{T,E}(x::Type{Rational{I}}) where {I<:Signed, T<:AbstractFloat, E<:Emphasis}
    numer = Double{T,E}(numerator(x))
    denom = Double{T,E}(denominator(x))
    return numer/denom
end
=#
#=
FastDouble() = Double{Float64, Performance}(zero(Float64), zero(Float64))
FastDouble(x::T) where {T<:AbstractFloat} =
    Double{Float64, Performance}(x, zero(Float64))
FastDouble(x::T, y::T) where {T<:AbstractFloat} =
    Double{Float64, Performance}(add_(x, y)...,)

FastDouble(x::T) where {T<:Real} =
    FastDouble{Float64, Performance}(Float64(x), zero(Float64))
FastDouble(x::T, y::T) where {T<:Real} =
    FastDouble{Float64, Performance}(add_(convert(Float64,x), convert(Float64,y))...,)
=#
