struct Double{T, E} <: MultipartFloat{T}
    hi::T
    lo::T

   function Double(::Type{Accuracy}, hi::T, lo::T)  where {T<:AbstractFloat}
       new{T, Accuracy}(hi, lo)
   end

   function Double(::Type{Performance}, hi::T, lo::T)  where {T<:AbstractFloat}
       new{T, Performance}(hi, lo)
   end
end

function Double(::Type{Accuracy}, hi::T) where {T<:AbstractFloat}
    return Double(Accuracy, hi, zero(T))
end

function Double(::Type{Performance}, hi::T) where {T<:AbstractFloat}
    return Double(Performance, hi, zero(T))
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
