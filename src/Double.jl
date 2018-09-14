struct DoubleFloat{T} <: MultipartFloat
   hi::T
   lo::T

   # these forms ensure hi, lo are canonically valued
   function DoubleFloat{T}(hi::T, lo::T) where {T<:IEEEFloat}
       hi, lo = add_2(hi, lo)
       return new{T}(hi, lo)
   end

   function DoubleFloat{DoubleFloat{T}}(hi::DoubleFloat{T}, lo::DoubleFloat{T}) where {T<:IEEEFloat}
     hi1, lo1 = HILO(hi)
     hi2, lo2 = HILO(lo)
     hihi, hilo, lohi, lolo = add_4(hi1, hi2, lo1, lo2)
     zhi = DoubleFloat{T}(hihi, hilo)
     zlo = DoubleFloat{T}(lohi, lolo)
     return new{DoubleFloat{T}}(zhi, zlo)
   end
   # this form does not alter hi, lo
   function DoubleFloat(hi::T, lo::T) where {T<:AbstractFloat}
       return new{T}(hi, lo)
   end
end



const Double64 = DoubleFloat{Float64}
const Double32 = DoubleFloat{Float32}
const Double16 = DoubleFloat{Float16}

const QuadrupleF64 = DoubleFloat{DoubleFloat{Float64}}
const QuadrupleF32 = DoubleFloat{DoubleFloat{Float32}}
const QuadrupleF16 = DoubleFloat{DoubleFloat{Float16}}


@inline HI(x::T) where {T<:IEEEFloat} = x
@inline LO(x::T) where {T<:IEEEFloat} = zero(F)
@inline HILO(x::T) where {T<:IEEEFloat} = x, zero(F)

@inline HI(x::T) where {F<:IEEEFloat, T<:DoubleFloat{F}} = x.hi
@inline LO(x::T) where {F<:IEEEFloat, T<:DoubleFloat{F}} = x.lo
@inline HILO(x::T) where {F<:IEEEFloat, T<:DoubleFloat{F}} = x.hi, x.lo

@inline HI(x::T) where {F<:IEEEFloat, G<:DoubleFloat{F}, T<:DoubleFloat{G}} = x.hi
@inline LO(x::T) where {F<:IEEEFloat, G<:DoubleFloat{F}, T<:DoubleFloat{G}} = x.lo
@inline HILO(x::T) where {F<:IEEEFloat, G<:DoubleFloat{F}, T<:DoubleFloat{G}} = x.hi, x.lo

@inline HI(x::Tuple{T,T}) where {T<:IEEEFloat} = x[1]
@inline LO(x::Tuple{T,T}) where {T<:IEEEFloat} = x[2]
@inline HILO(x::Tuple{T,T}) where {T<:IEEEFloat} = x

@inline HI(x::Tuple{T,T}) where {F<:IEEEFloat, T<:DoubleFloat{F}} = x[1]
@inline LO(x::Tuple{T,T}) where {F<:IEEEFloat, T<:DoubleFloat{F}} = x[2]
@inline HILO(x::Tuple{T,T}) where {F<:IEEEFloat, T<:DoubleFloat{F}} = x

@inline HI(x::Tuple{T,T}) where {F<:IEEEFloat, T<:DoubleFloat{DoubleFloat{F}}} = x[1]
@inline LO(x::Tuple{T,T}) where {F<:IEEEFloat, T<:DoubleFloat{DoubleFloat{F}}} = x[2]
@inline HILO(x::Tuple{T,T}) where {F<:IEEEFloat, T<:DoubleFloat{DoubleFloat{F}}} = x

@inline Double64(x::Tuple{Float64,Float64}) = DoubleFloat(x[1], x[2])
@inline Double32(x::Tuple{Float32,Float32}) = DoubleFloat(x[1], x[2])
@inline Double16(x::Tuple{Float16,Float16}) = DoubleFloat(x[1], x[2])
@inline Double64(x::Tuple{T,T}) where {T<:IEEEFloat} = DoubleFloat(Float64(x[1]), Float64(x[2]))
@inline Double32(x::Tuple{T,T}) where {T<:IEEEFloat} = DoubleFloat(Float32(x[1]), Float32(x[2]))
@inline Double16(x::Tuple{T,T}) where {T<:IEEEFloat} = DoubleFloat(Float16(x[1]), Float16(x[2]))
@inline DoubleFloat(x::Tuple{T,T}) where {T<:AbstractFloat} = DoubleFloat{T}(x[1], x[2])

@inline function Double64(x::T) where {T<:IEEEFloat}
    !isfinite(x) && return(DoubleFloat(Float64(x),Float64(NaN)))
    hi = Float64(x)
    lo = Float64(x - Float64(hi))
    return Double64(hi, lo)
end
@inline function Double32(x::T) where {T<:IEEEFloat}
    !isfinite(x) && return(DoubleFloat(Float32(x),Float32(NaN)))
    hi = Float32(x)
    lo = Float32(x - Float64(hi))
    return Double32(hi, lo)
end
@inline function Double16(x::T) where {T<:IEEEFloat}
    !isfinite(x) && return(DoubleFloat(Float16(x),Float16(NaN)))
    hi = Float16(x)
    lo = Float16(x - Float64(hi))
    return Double16(hi, lo)
end

@inline Double64(hi::T) where {T<:Integer} = Double64(Float64(hi))
@inline Double32(hi::T) where {T<:Integer} = Double32(Float32(hi))
@inline Double16(hi::T) where {T<:Integer} = Double16(Float16(hi))

for (F,D,U) in ((:Float64, :Double64, :(Union{Float32, Float16})),
                (:Float32, :Double32, :(Union{Float64, Float16})),
                (:Float16, :Double16, :(Union{Float64, Float32})))
  @eval begin
    @inline $D(hi::T, lo::T) where {T<:$U} = $D($F(hi), $F(lo))
    @inline $D(hi::T, lo::I) where {T<:$U, I<:Integer} = $D($F(hi), $F(lo))
    @inline $D(hi::I, lo::T) where {T<:$U, I<:Integer} = $D($F(hi), $F(lo))
    @inline $D(hi::I, lo::I) where {I<:Integer} = $D($F(hi), $F(lo))
  end
end


DoubleFloat{T}(x::DoubleFloat{T}, y::T) where {T<:IEEEFloat} = DoubleFloat(x, DoubleFloat(y))
DoubleFloat{T}(x::T, y::DoubleFloat{T}) where {T<:IEEEFloat} = DoubleFloat(DoubleFloat(x), y)
DoubleFloat{T}(x::DoubleFloat{T}, y::DoubleFloat{T}) where {T<:IEEEFloat} = DoubleFloat(x,y)

DoubleFloat{T}(x::DoubleFloat{DoubleFloat{T}}, y::T) where {T<:IEEEFloat} = DoubleFloat(x, DoubleFloat(DoubleFloat(y),DoubleFloat(zero(T))))
DoubleFloat{T}(x::T, y::DoubleFloat{DoubleFloat{T}}) where {T<:IEEEFloat} = DoubleFloat(DoubleFloat(DoubleFloat(x), DoubleFloat(zero(T))), y)
DoubleFloat{T}(x::DoubleFloat{DoubleFloat{T}}, y::DoubleFloat{T}) where {T<:IEEEFloat} = DoubleFloat(x, DoubleFloat(y, DoubleFloat(zero(T))))
DoubleFloat{T}(x::DoubleFloat{T}, y::DoubleFloat{DoubleFloat{T}}) where {T<:IEEEFloat} = DoubleFloat(DoubleFloat(x, DoubleFloat(zero(T))), y)
DoubleFloat{T}(x::DoubleFloat{DoubleFloat{T}}, y::DoubleFloat{DoubleFloat{T}}) where {T<:IEEEFloat} = DoubleFloat(x,y)

Double64(x::Double32) = Double64(add_2(Float64(HI(x)), Float64(LO(x))))
Double64(x::Double16) = Double64(add_2(Float64(HI(x)), Float64(LO(x))))
Double32(x::Double16) = Double32(add_2(Float32(HI(x)), Float32(LO(x))))
Double32(x::Double64) = Double32(BigFloat(x))
Double16(x::Double64) = Double16(BigFloat(x))
Double16(x::Double32) = Double16(BigFloat(x))


# a type specific hash function helps the type to 'just work'
const hash_double_lo = (UInt === UInt64) ? 0x9bad5ebab034fe78 : 0x72da40cb
const hash_0_double_lo = hash(zero(UInt), hash_double_lo)

@inline Base.hash(z::DoubleFloat{T}, h::UInt) where {T<:IEEEFloat} =
    hash(z.hi, h) ⊻ hash(z.lo)

@inline Base.hash(z::DoubleFloat{T}, h::UInt) where {F<:IEEEFloat, T<:DoubleFloat{F}} =
    hash(z.hi) ⊻ hash(z.lo)

@inline Base.hash(z::DoubleFloat{T}, h::UInt) where {F<:IEEEFloat, G<:DoubleFloat{F}, T<:DoubleFloat{G}} =
    hash(z.hi) ⊻ hash(z.lo)

Base.precision(::DoubleFloat{T}) where {T<:IEEEFloat} = 2 * precision(T)
