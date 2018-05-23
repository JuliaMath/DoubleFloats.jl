convert(::Type{DoubleFloat{T}}, x::T) where {T<:IEEEFloat} = DoubleFloat{T}(x)
convert(::Type{T}, x::DoubleFloat{T}) where {T<:IEEEFloat} = HI(x)

convert(::Type{DoubleFloat{T}}, x::I) where {T<:IEEEFloat, I<:Integer} = DoubleFloat{T}(T(x))
convert(::Type{I}, x::DoubleFloat{T}) where {T<:IEEEFloat, I<:Integer} = I(round(Base.BigInt,Base.BigFloat(HI(x))+Base.BigFloat(LO(x))))

function convert(::Type{Base.BigFloat}, x::DoubleFloat{T}) where {T<:AbstractFloat}
    res = Base.BigFloat(HI(x)) + Base.BigFloat(LO(x))
    return res
end
function convert(::Type{DoubleFloat{T}}, x::Base.BigFloat) where {T<:AbstractFloat}
    hi = T(x)
    lo = T(x - hi)
    return DoubleFloat(hi, lo)
end
  
function convert(::Type{Base.BigInt}, x::DoubleFloat{T}) where {T<:AbstractFloat}
    res = round(Base.BigInt, Base.BigFloat(HI(x)) + Base.BigFloat(LO(x)))
    return res
end
function convert(::Type{DoubleFloat{T}}, x::Base.BigInt) where {T<:AbstractFloat}
    return convert(DoubleFloat{T}, Bse.BigFloat(x))
end

convert(::Type{DoubleFloat{T}}, x::DoubleFloat{DoubleFloat{T}}) where {T<:IEEEFloat} = HI(x)
convert(::Type{DoubleFloat{DoubleFloat{T}}}, x::DoubleFloat{T}) where {T<:IEEEFloat} = DoubleFloat(x, DoubleFloat{T}(zero(T)))

convert(::Type{T}, x::DoubleFloat{DoubleFloat{T}}) where {T<:IEEEFloat} = HI(HI(x))
convert(::Type{DoubleFloat{DoubleFloat{T}}}, x::T) where {T<:IEEEFloat} = DoubleFloat(DoubleFloat{T}(x), DoubleFloat{T}(zero(T)))
