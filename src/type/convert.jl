convert(::Type{DoubleFloat{T}}, x::T) where {T<:IEEEFloat} = DoubleFloat{T}(x)
convert(::Type{T}, x::DoubleFloat{T}) where {T<:IEEEFloat} = HI(x)

convert(::Type{DoubleFloat{T}}, x::I) where {T<:IEEEFloat, I<:Integer} = DoubleFloat{T}(T(x))
convert(::Type{I}, x::DoubleFloat{T}) where {T<:IEEEFloat, I<:Integer} = I(round(BigInt, BigFloat(HI(x))+ BigFloat(LO(x))))

function convert(::Type{BigFloat}, x::DoubleFloat{T}) where {T<:AbstractFloat}
    res = Base.BigFloat(HI(x)) + Base.BigFloat(LO(x))
    return res
end
function convert(::Type{DoubleFloat{T}}, x::BigFloat) where {T<:AbstractFloat}
    hi = T(x)
    lo = T(x - hi)
    return DoubleFloat(hi, lo)
end
  
function convert(::Type{BigInt}, x::DoubleFloat{T}) where {T<:IEEEFloat}
    res = round(Base.BigInt, Base.BigFloat(HI(x)) + Base.BigFloat(LO(x)))
    return res
end
function convert(::Type{DoubleFloat{T}}, x::BigInt) where {T<:IEEEFloat}
    return convert(DoubleFloat{T}, BigFloat(x))
end

convert(::Type{DoubleFloat{T}}, x::DoubleFloat{DoubleFloat{T}}) where {T<:IEEEFloat} = HI(x)
convert(::Type{DoubleFloat{DoubleFloat{T}}}, x::DoubleFloat{T}) where {T<:IEEEFloat} = DoubleFloat(x, DoubleFloat{T}(zero(T)))

convert(::Type{T}, x::DoubleFloat{DoubleFloat{T}}) where {T<:IEEEFloat} = HI(HI(x))
convert(::Type{DoubleFloat{DoubleFloat{T}}}, x::T) where {T<:IEEEFloat} = DoubleFloat(DoubleFloat{T}(x), DoubleFloat{T}(zero(T)))

convert(::Type{DoubleFloat{T}}, x::Tuple{T,T}) where {T<:IEEEFloat} = DoubleFloat{T}(x[1],x[2])
 
