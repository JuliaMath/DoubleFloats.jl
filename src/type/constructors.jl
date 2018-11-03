Base.Float64(x::DoubleFloat{T}) where {T<:IEEEFloat} = Float64(HI(x))
Base.Float32(x::DoubleFloat{T}) where {T<:IEEEFloat} = Float32(Float64(x))
Base.Float16(x::DoubleFloat{T}) where {T<:IEEEFloat} = Float16(Float64(x))

Base.Int128(x::DoubleFloat{T}) where {T<:IEEEFloat} = Int128(round(BigInt, BigFloat(HI(x)) + BigFloat(LO(x))))
Base.Int64(x::DoubleFloat{T}) where {T<:IEEEFloat} = Int64(round(BigInt, BigFloat(HI(x)) + BigFloat(LO(x))))
Base.Int32(x::DoubleFloat{T}) where {T<:IEEEFloat} = Int32(round(BigInt, BigFloat(HI(x)) + BigFloat(LO(x))))
Base.Int16(x::DoubleFloat{T}) where {T<:IEEEFloat} = Int16(round(BigInt, BigFloat(HI(x)) + BigFloat(LO(x))))
Base.Int8(x::DoubleFloat{T}) where {T<:IEEEFloat} = Int8(round(BigInt, BigFloat(HI(x)) + BigFloat(LO(x))))

Base.BigFloat(x::DoubleFloat{T}) where {T<:AbstractFloat} = BigFloat(HI(x)) + BigFloat(LO(x))

Base.BigFloat(x::DoubleFloat{DoubleFloat{T}}) where {T<:IEEEFloat} =
    BigFloat(HI(HI(x))) + BigFloat(LO(HI(x))) + BigFloat(HI(LO(x))) + BigFloat(LO(LO(x)))


for (F,D) in ((:Float64, :Double64), (:Float32, :Double32), (:Float16, :Double16))
  @eval begin
    function Base.$D(x::BigFloat)
        hi = $F(x)
        lo = $F(x - hi)
        return $D(hi, lo)
    end
    Base.$D(x::BigInt) = $D(BigFloat(x))
  end
end


function DoubleFloat{DoubleFloat{T}}(x::BigFloat) where {T<:IEEEFloat}
    hihi = T(x)
    hilo = T(x - hihi)
    lohi = T(x - hihi - hilo)
    lolo = T(x - hihi - hilo - lohi)
    hi = DoubleFloat(hihi, hilo)
    lo = DoubleFloat(lohi, lolo)
    return DoubleFloat(hi, lo)
end
DoubleFloat{DoubleFloat{T}}(x::BigInt) where {T<:IEEEFloat} =
    DoubleFloat{DoubleFloat{T}}(Base.BigFloat(x))

DoubleFloat{T}(x::DoubleFloat{DoubleFloat{T}}) where {T<:IEEEFloat} = HI(x)
DoubleFloat{DoubleFloat{T}}(x::DoubleFloat{T}) where {T<:IEEEFloat} =
    DoubleFloat{DoubleFloat{T}}(x, DoubleFloat(zero(T)))

Double64(x::Irrational{S}) where {S} = Double64(BigFloat(x))
Double32(x::Irrational{S}) where {S} = Double32(BigFloat(x))
Double16(x::Irrational{S}) where {S} = Double16(BigFloat(x))
