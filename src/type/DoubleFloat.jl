import Base: Float16, Float32, Float64, BigFloat

struct Double{T, E<:Emphasis} <: AbstractDouble{T}
    hi::T
    lo::T
    
    function Double{T, E}(x::T) where {T<:IEEEFloat, E<:Emphasis}
        new{T,E}(x, zero(T))
    end
    function Double{T, E}(x::T, y::T) where {T<:IEEEFloat, E<:Emphasis}
        hi, lo = add_2(x, y)
        new{T,E}(hi, lo)
    end
end

@inline HI(x::Double{T,E}) where {T,E<:Emphasis} = x.hi
@inline LO(x::Double{T,E}) where {T,E<:Emphasis} = x.lo
@inline HILO(x::Double{T,E}) where {T,E<:Emphasis} = (x.hi, x.lo)

@inline HI(x::Tuple{T,T}) where {T} = x[1]
@inline LO(x::Tuple{T,T}) where {T} = x[2]
@inline HILO(x::Tuple{T,T}) where {T} = x

@inline HI(x::T) where {T<:IEEEFloat} = x
@inline LO(x::T) where {T<:IEEEFloat} = zero(T)
@inline HILO(x::T) where {T<:IEEEFloat} = (x, zero(T))

# this and the four inlines below are present so `zero(FastDouble)` etc just work
struct FastDouble{T} <: AbstractDouble{T}
    hi::T
    lo::T
    
    function FastDouble(z::FastDouble{T}) where {T}
        return new{T}(HI(z), LO(z))
    end
end

@inline FastDouble(x::Double{T, Performance}) where {T<:AbstractFloat} = x
@inline FastDouble(x::Double{T, Accuracy}) where {T<:AbstractFloat} =
    Double(Performance, HI(x), LO(x))

@inline FastDouble(hi::T) where {T<:AbstractFloat} = Double{T,Performance}(hi, zero(T))
@inline FastDouble(hi::T, lo::T) where {T<:AbstractFloat} = Double(Performance, hi, lo)


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

include("constructors.jl")
include("val_isa_cmp.jl")
include("string_show.jl")
