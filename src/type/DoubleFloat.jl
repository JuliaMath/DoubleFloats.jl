import Base: Float16, Float32, Float64, BigFloat

struct Double{T, E<:Emphasis} <: AbstractDouble{T}
    hi::T
    lo::T
end

struct FastDouble{T} <: AbstractDouble{T}
    hi::T
    lo::T
end
    
@inline FastDouble(x::Double{T, Performance}) where {T<:AbstractDouble} = x
@inline FastDouble(x::Double{T, Accuracy}) where {T<:AbstractDouble} = Double{T, Performance}(x.hi, x.lo)
@inline FastDouble(hi::T) where {T<:AbstractDouble} = Double{T,Performance}(hi, zero(T))
@inline FastDouble(hi::T, lo::T) where {T<:AbstractDouble} = Double(Performance, hi, lo)

@inline HI(x::Double{T,E}) where {T,E<:Emphasis} = x.hi
@inline LO(x::Double{T,E}) where {T,E<:Emphasis} = x.lo
@inline HILO(x::Double{T,E}) where {T,E<:Emphasis} = (x.hi, x.lo)

@inline HI(x::Tuple{T,T}) where {T} = x[1]
@inline LO(x::Tuple{T,T}) where {T} = x[2]
@inline HILO(x::Tuple{T,T}) where {T} = x

@inline HI(x::T) where {T<:IEEEFloat} = x
@inline LO(x::T) where {T<:IEEEFloat} = zero(T)
@inline HILO(x::T) where {T<:IEEEFloat} = (x, zero(T))

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
