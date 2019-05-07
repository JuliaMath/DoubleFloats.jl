@inline Base.Float64(x::DoubleFloat{T}) where {T<:IEEEFloat} = Float64(HI(x))
@inline Base.Float32(x::DoubleFloat{T}) where {T<:IEEEFloat} = Float32(Float64(x))
@inline Base.Float16(x::DoubleFloat{T}) where {T<:IEEEFloat} = Float16(Float64(x))

Base.Int128(x::DoubleFloat{T}) where {T<:IEEEFloat} = Int128(round(BigInt, BigFloat(HI(x)) + BigFloat(LO(x))))
Base.Int64(x::DoubleFloat{T}) where {T<:IEEEFloat} = Int64(round(BigInt, BigFloat(HI(x)) + BigFloat(LO(x))))
Base.Int32(x::DoubleFloat{T}) where {T<:IEEEFloat} = Int32(round(BigInt, BigFloat(HI(x)) + BigFloat(LO(x))))
Base.Int16(x::DoubleFloat{T}) where {T<:IEEEFloat} = Int16(round(BigInt, BigFloat(HI(x)) + BigFloat(LO(x))))
Base.Int8(x::DoubleFloat{T}) where {T<:IEEEFloat} = Int8(round(BigInt, BigFloat(HI(x)) + BigFloat(LO(x))))

@inline Base.BigFloat(x::DoubleFloat{T}) where {T<:IEEEFloat} = BigFloat(HI(x)) + BigFloat(LO(x))
@inline Base.BigInt(x::DoubleFloat{T}) where {T<:IEEEFloat} = BigInt(BigFloat(x))

for (F,D) in ((:Float64, :Double64), (:Float32, :Double32), (:Float16, :Double16))
  @eval begin
    function $D(x::BigFloat)
        hi = $F(x)
        lo = $F(x - hi)
        return $D(hi, lo)
    end
    $D(x::BigInt) = $D(BigFloat(x))
  end
end


# constants for BigFloat precision are > 2*significandbits(DoubleT)

Double64(x::Irrational{S}) where {S} = Double64(BigFloat(x, 250))
Double32(x::Irrational{S}) where {S} = Double32(BigFloat(x, 122))
Double16(x::Irrational{S}) where {S} = Double16(BigFloat(x,  60))

Double64(x::Rational{S}) where {S} = Double64(BigFloat(x, 250))
Double32(x::Rational{S}) where {S} = Double32(BigFloat(x, 122))
Double16(x::Rational{S}) where {S} = Double16(BigFloat(x,  60))

Complex{Double64}(x::T) where {T<:AbstractIrrational} = Complex(Double64(x))
Complex{Double32}(x::T) where {T<:AbstractIrrational} = Complex(Double32(x))
Complex{Double16}(x::T) where {T<:AbstractIrrational} = Complex(Double16(x))
