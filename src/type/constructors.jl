DoubleFloat{Float64}(x::Float64) = DoubleFloat{Float64}(x, zero(Float64))
DoubleFloat{Float32}(x::Float64) = DoubleFloat{Float32}(x, zero(Float64))
DoubleFloat{Float16}(x::Float16) = DoubleFloat{Float16}(x, zero(Float16))

Float64(x::DoubleFloat{T}) where {T<:IEEEFloat} = Float64(HI(x))
Float32(x::DoubleFloat{T}) where {T<:IEEEFloat} = Float32(Float64(x))
Float16(x::DoubleFloat{T}) where {T<:IEEEFloat} = Float16(Float64(x))

DoubleFloat{Float64}(x::Int64) = DoubleFloat{Float64}(BigFloat(x)) 
DoubleFloat{Float32}(x::Int32) = DoubleFloat{Float32}(BigFloat(x)) 
DoubleFloat{Float16}(x::Int16) = DoubleFloat{Float16}(BigFloat(x)) 

DoubleFloat{T}(x::Int128) where {T<:IEEEFloat} = DoubleFloat{T}(BigFloat(x))
DoubleFloat{T}(x::Int64) where {T<:IEEEFloat}  = DoubleFloat{T}(BigFloat(x))
DoubleFloat{T}(x::Int32) where {T<:IEEEFloat}  = DoubleFloat{T}(BigFloat(x))
DoubleFloat{T}(x::Int16) where {T<:IEEEFloat}  = DoubleFloat{T}(BigFloat(x))

DoubleF64(x::Int32) = DoubleFloat{Float64}(Float64(x))
DoubleF64(x::Int16) = DoubleFloat{Float64}(Float64(x))
DoubleF64(x::Int8)  = DoubleFloat{Float64}(Float64(x))
DoubleF32(x::Int16) = DoubleFloat{Float32}(Float32(x))
DoubleF32(x::Int8)  = DoubleFloat{Float32}(Float32(x))
DoubleF16(x::Int8)  = DoubleFloat{Float16}(Float16(x))


Int128(x::DoubleFloat{T}) where {T<:IEEEFloat} = Int128(round(Base.BigInt, Base.BigFloat(HI(x)) + Base.BigFloat(LO(x))))
Int64(x::DoubleFloat{T}) where {T<:IEEEFloat} = Int64(round(Base.BigInt, Base.BigFloat(HI(x)) + Base.BigFloat(LO(x))))
Int32(x::DoubleFloat{T}) where {T<:IEEEFloat} = Int32(round(Base.BigInt, Base.BigFloat(HI(x)) + Base.BigFloat(LO(x))))
Int16(x::DoubleFloat{T}) where {T<:IEEEFloat} = Int16(round(Base.BigInt, Base.BigFloat(HI(x)) + Base.BigFloat(LO(x))))
Int8(x::DoubleFloat{T}) where {T<:IEEEFloat} = Int8(round(Base.BigInt, Base.BigFloat(HI(x)) + Base.BigFloat(LO(x))))

Base.BigFloat(x::DoubleFloat{T}) where {T<:AbstractFloat} = Base.BigFloat(HI(x)) + Base.BigFloat(LO(x))

Base.BigFloat(x::DoubleFloat{DoubleFloat{T}}) where {T<:IEEEFloat} =
    Base.BigFloat(HI(HI(x))) + Base.BigFloat(LO(HI(x))) + Base.BigFloat(HI(LO(x))) + Base.BigFloat(LO(LO(x)))


for (F,D) in ((:(Base.Float64), :DoubleF64), (:(Base.Float32), :DoubleF32), (:(Base.Float16), :DoubleF16))
  @eval begin
    function $D(x::Base.BigFloat)
        hi = $F(x)
        lo = $F(x - hi)
        return $D(hi, lo)
    end
    $D(x::Base.BigInt) = $D(Base.BigFloat(x))
  end
end


function DoubleFloat{DoubleFloat{T}}(x::Base.BigFloat) where {T<:IEEEFloat}
    hihi = T(x)
    hilo = T(x - hihi)
    lohi = T(x - hihi - hilo)
    lolo = T(x - hihi - hilo - lohi)
    hi = DoubleFloat(hihi, hilo)
    lo = DoubleFloat(lohi, lolo)
    return DoubleFloat(hi, lo)
end
DoubleFloat{DoubleFloat{T}}(x::Base.BigInt) where {T<:IEEEFloat} =
    DoubleFloat{DoubleFloat{T}}(Base.BigFloat(x))

DoubleFloat{T}(x::DoubleFloat{DoubleFloat{T}}) where {T<:IEEEFloat} = HI(x)
DoubleFloat{DoubleFloat{T}}(x::DoubleFloat{T}) where {T<:IEEEFloat} =
    DoubleFloat{DoubleFloat{T}}(x, DoubleFloat(zero(T)))

DoubleFloat{DoubleFloat{T}}(x::T) where {T<:IEEEFloat} =
    DoubleFloat{DoubleFloat{T}}(DoubleFloat{T}(x), DoubleFloat(zero(T)))

DoubleF64(x::Irrational{S}) where {S} = DoubleF64(Base.BigFloat(x))
DoubleF32(x::Irrational{S}) where {S} = DoubleF32(Base.BigFloat(x))
DoubleF16(x::Irrational{S}) where {S} = DoubleF16(Base.BigFloat(x))
