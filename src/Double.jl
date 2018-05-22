struct Double{T, E} <: MultipartFloat{T}
    hi::T
    lo::T

    function Double(::Type{E}, hi::T, lo::T) where {T<:AbstractFloat, E<:Emphasis}
        new{T,E}(hi, lo)
    end
end

@inline HI(x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis} = x.hi
@inline LO(x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis} = x.lo
@inline HILO(x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis} = x.hi, x.lo

@inline HI(x::T) where {T<:AbstractFloat} = x
@inline LO(x::T) where {T<:AbstractFloat} = zero(T)
@inline HILO(x::T) where {T<:AbstractFloat} = x, zero(T)

@inline HI(x::Tuple{T,T}) where {T<:AbstractFloat} = x[1]
@inline LO(x::Tuple{T,T}) where {T<:AbstractFloat} = x[2]
@inline HILO(x::Tuple{T,T}) where {T<:AbstractFloat} = x[1], x[2]

@inline HI(x::Tuple{T}) where {T<:AbstractFloat} = x[1]
@inline LO(x::Tuple{T}) where {T<:AbstractFloat} = zero(T)
@inline HILO(x::Tuple{T}) where {T<:AbstractFloat} = x[1], zero(T)

function Double{T, Accuracy}(hi::T, lo::T) where {T<:AbstractFloat}
    hi, lo = two_sum(hi, lo)
    Double(Accuracy, hi, lo)
end
function Double{T, Performance}(hi::T, lo::T) where {T<:AbstractFloat}
    hi, lo = two_sum(hi, lo)
    Double(Performance, hi, lo)
end

function Double(::Type{E}, hi::T) where {T<:AbstractFloat, E<:Emphasis}
    return Double(E, hi, zero(T))
end

function Double(::Type{E}, hi::Tuple{T}) where {T<:AbstractFloat, E<:Emphasis}
    return Double(E, hi[1], zero(T))
end

function Double(::Type{E}, hilo::Tuple{T,T}) where {T<:AbstractFloat, E<:Emphasis}
    hi, lo = two_sum(hilo[1], hilo[2])
    return Double(E, hi, lo)
end

function Double(hi::T, lo::T) where {T<:AbstractFloat}
    return Double{T, Accuracy}(hi, lo)
end

function Double(hi::T) where {T<:AbstractFloat}
    lo = zero(T)
    return Double(Accuracy, hi, lo)
end

function FastDouble(hi::T, lo::T) where {T<:AbstractFloat}
    return Double{T, Performance}(hi, lo)
end

function FastDouble(hi::T) where {T<:AbstractFloat}
    lo = zero(T)
    return Double(Performance, hi, lo)
end


Double(x::Double{T, Accuracy}) where {T<:AbstractFloat} = x

FastDouble(x::Double{T, Performance}) where {T<:AbstractFloat} = x

Double(::Type{T}, x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis} = x
FastDouble(::Type{T}, x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis} = x

function Double(::Type{T1}, x::Double{T2,E}) where {T1<:IEEEFloat, T2<:IEEEFloat, E<:Emphasis}
    if sizeof(T1) > sizeof(T2)
        hi,lo = TwoSum(T1(HI(x)), T1(LO(x)))
    else
        hi = T1(HI(x))
        lo = T1(HI(x) - hi)
    end
    return Double(Accuracy, hi, lo)
end

function FastDouble(::Type{T1}, x::Double{T2,E}) where {T1<:IEEEFloat, T2<:IEEEFloat, E<:Emphasis}
    if sizeof(T1) > sizeof(T2)
        hi,lo = TwoSum(T1(HI(x)), T1(LO(x)))
    else
        hi = T1(HI(x))
        lo = T1(HI(x) - hi)
    end
    return Double(Performance, hi, lo)
end

Double(::Type{E}, x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis} = x
FastDouble(::Type{E}, x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis} = x

Double(x::Double{T,Performance}) where {T<:AbstractFloat} = Double(Accuracy, HI(x), LO(x))
FastDouble(x::Double{T,Accuracy}) where {T<:AbstractFloat} = Double(Performance, HI(x), LO(x))


const BigFloatStrBits = 120 # 116 may be enough


function string(x::Double{T, Accuracy}) where {T<:AbstractFloat}
    return string("Double(",HI(x),", ",LO(x),")")
end

function string(x::Double{T, Performance}) where {T<:AbstractFloat}
    return string("FastDouble(",HI(x),", ",LO(x),")")
end

function show(io::IO, x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
    prec = precision(BigFloat)
    setprecision(BigFloat, BigFloatStrBits)
    str = string(BigFloat(HI(x)) + BigFloat(LO(x)))
    setprecision(BigFloat, prec)
    print(io, str)
end

function parse(::Type{Double{T,Accuracy}}, str::AbstractString) where {T<:AbstractFloat}
    if startswith(str, "FastDouble")
        str = str[5:end]
    end
    if !startswith(str,"Double")
        throw(ErrorException("$str is not recognized as a Double"))
    end
    str = str[8:end-1]
    if contains(str, ", ")
        histr, lostr = split(str, ", ")
    else
        histr, lostr = split(str, ",")
    end
    hi = parse(T, histr)
    lo = parse(T, lostr)
    hi, lo = two_sum(hi, lo)
    return Double{T, Accuracy}(hi, lo)
end

function parse(::Type{Double{T, Performance}}, str::AbstractString) where {T<:AbstractFloat}
    if startswith(str, "Double")
        str = string("Fast", str)
    end
    if !startswith(str,"FastDouble")
        throw(ErrorException("$str is not recognized as a FastDouble"))
    end
    str = str[12:end-1]
    if contains(str, ", ")
        histr, lostr = split(str, ", ")
    else
        histr, lostr = split(str, ",")
    end
    hi = parse(T, histr)
    lo = parse(T, lostr)
    hi, lo = two_sum(hi, lo)
    return Double{T, Performance}(hi, lo)
end

parse(Double, str::AbstractString) = parse(Double{Float64, Accuracy}, str)

parse(::Type{Val{FastDouble}}, str::AbstractString) = parse(Double{Float64, Performance}, str)


# a fast type specific hash function helps
import Base: hash, hx, fptoui

const hash_doublefloat_lo = (UInt === UInt64) ? 0x9bad5ebab034fe78 : 0x72da40cb
const hash_0_dfloat_lo = hash(zero(UInt), hash_doublefloat_lo)
const hash_accuracy_lo = hash(hash(Accuracy), hash_doublefloat_lo)
const hash_performance_lo = hash(hash(Performance), hash_doublefloat_lo)

function hash(x::Double{T,Accuracy}, h::UInt) where {T}
    !isnan(HI(x)) ?
       ( iszero(LO(x)) ?
            hx(fptoui(UInt64, abs(HI(x))), HI(x), h ⊻ hash_accuracy_lo) :
            hx(fptoui(UInt64, abs(HI(x))), LO(x), h ⊻ hash_accuracy_lo)
       ) : (hx_NaN ⊻ h)
end

function hash(x::Double{T,Performance}, h::UInt) where {T}
    !isnan(HI(x)) ?
       ( iszero(LO(x)) ?
            hx(fptoui(UInt64, abs(HI(x))), HI(x), h ⊻ hash_performance_lo) :
            hx(fptoui(UInt64, abs(HI(x))), LO(x), h ⊻ hash_performance_lo)
       ) : (hx_NaN ⊻ h)
end
