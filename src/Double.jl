struct Double{T, E} <: MultipartFloat{T}
    hi::T
    lo::T

   function Double{T, Accuracy}(hi::T, lo::T) where {T<:IEEEFloat}
        hi, lo =  add_2(hi, lo)
        new{T, Accuracy}(hi, lo)
   end
   function Double{T, Performance}(hi::T, lo::T) where {T<:IEEEFloat}
        hi, lo =  add_2(hi, lo)
        new{T, Performance}(hi, lo)
   end
   function Double(::Type{Accuracy}, hi::T, lo::T)  where {T<:IEEEFloat}
       new{T, Accuracy}(hi, lo)
   end

   function Double(::Type{Performance}, hi::T, lo::T)  where {T<:IEEEFloat}
       new{T, Performance}(hi, lo)
   end
end

function Double(::Type{Accuracy}, hi::T) where {T<:AbstractFloat}
    return Double(Accuracy, hi, zero(T))
end

function Double(::Type{Performance}, hi::T) where {T<:AbstractFloat}
    return Double(Performance, hi, zero(T))
end

function Double(::Type{Accuracy}, hi::Tuple{T}) where {T<:AbstractFloat}
    return Double(Accuracy, hi[1], zero(T))
end

function Double(::Type{Performance}, hi::Tuple{T}) where {T<:AbstractFloat}
    return Double(Performance, hi[1], zero(T))
end

function Double(::Type{Accuracy}, hilo::Tuple{T,T}) where {T<:AbstractFloat}
    hi, lo = two_sum(hilo[1], hilo[2])
    return Double(Accuracy, hi, lo)
end

function Double(::Type{Performance}, hilo::Tuple{T,T}) where {T<:AbstractFloat}
    hi, lo = two_sum(hilo[1], hilo[2])
    return Double(Performance, hi, lo)
end

function Double{T, Accuracy}(hi::T, lo::T) where {T<:AbstractFloat}
    hi, lo = two_sum(hi, lo)
    return Double(Accuracy, hi, lo)
end

function Double{T, Performance}(hi::T, lo::T) where {T<:AbstractFloat}
    hi, lo = two_sum(hi, lo)
    return Double(Performance, hi, lo)
end

function Double{T, Accuracy}(hi::T) where {T<:AbstractFloat}
    return Double(Accuracy, hi, zero(T))
end

function Double{T, Performance}(hi::T) where {T<:AbstractFloat}
    return Double(Performance, hi, zero(T))
end

function Double(hi::T, lo::T) where {T<:AbstractFloat}
    return Double{T, Accuracy}(hi, lo)
end

function Double(hi::T) where {T<:AbstractFloat}
    return Double{T, Accuracy}(hi)
end

function FastDouble(hi::T, lo::T) where {T<:AbstractFloat}
    return Double{T, Performance}(hi, lo)
end

function FastDouble(hi::T) where {T<:AbstractFloat}
    return Double{T, Performance}(hi)
end


function Double(x::Double{T, Performance}) where {T<:AbstractFloat}
    return Double(Accuracy, HILO(x))
end

function FastDouble(x::Double{T, Accuracy}) where {T<:AbstractFloat}
    return Double(Performance, HILO(x))
end

function Double(x::Double{T, Accuracy}) where {T<:AbstractFloat}
    return x
end

function FastDouble(x::Double{T, Performance}) where {T<:AbstractFloat}
    return x
end


HI(x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis} = x.hi
LO(x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis} = x.lo
HILO(x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis} = x.hi, x.lo

HI(x::T) where {T<:IEEEFloat} = x
LO(x::T) where {T<:IEEEFloat} = zero(T)
HILO(x::T) where {T<:IEEEFloat} = x, zero(T)

HI(x::Tuple{T,T}) where {T<:IEEEFloat} = x[1]
LO(x::Tuple{T,T}) where {T<:IEEEFloat} = x[2]
HILO(x::Tuple{T,T}) where {T<:IEEEFloat} = x


function string(x::Double{T, Accuracy}) where {T<:AbstractFloat}
    return string("Double(",HI(x),", ",LO(x),")")
end

function string(x::Double{T, Performance}) where {T<:AbstractFloat}
    return string("FastDouble(",HI(x),", ",LO(x),")")
end

function show(io::IO, x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
    str = string(x)
    print(io, str)
end

function show(x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
    str = string(x)
    print(StdOutStream, str)
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
