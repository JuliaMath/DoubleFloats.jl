Base.convert(::Type{Double64}, x::Double64) = x
Base.convert(::Type{Double32}, x::Double32) = x
Base.convert(::Type{Double16}, x::Double16) = x

Base.convert(::Type{ComplexDF64}, x::ComplexDF64) = x
Base.convert(::Type{ComplexDF32}, x::ComplexDF32) = x
Base.convert(::Type{ComplexDF16}, x::ComplexDF16) = x

Base.convert(::Type{Float64}, x::Double64) = HI(x)
Base.convert(::Type{Float32}, x::Double32) = HI(x)
Base.convert(::Type{Float16}, x::Double16) = HI(x)

Base.convert(::Type{DoubleFloat{T}}, x::I) where {T<:IEEEFloat,I<:Integer} = DoubleFloat{T}(T(x))

function Base.convert(::Type{I}, x::DoubleFloat{T}) where {T<:IEEEFloat,I<:Integer}
    bi = trunc(BigInt, BigFloat(HI(x)) + BigFloat(LO(x)))
    convert(Int64, bi)
end

function Base.convert(::Type{BigFloat}, x::DoubleFloat{T}) where {T<:IEEEFloat}
    res = Base.BigFloat(HI(x)) + Base.BigFloat(LO(x))
    return res
end
function Base.convert(::Type{DoubleFloat{T}}, x::BigFloat) where {T<:IEEEFloat}
    hi = T(x)
    lo = T(x - hi)
    return DoubleFloat(hi, lo)
end

function Base.convert(::Type{BigInt}, x::DoubleFloat{T}) where {T<:IEEEFloat}
    res = round(Base.BigInt, Base.BigFloat(HI(x)) + Base.BigFloat(LO(x)))
    return res
end
function Base.convert(::Type{DoubleFloat{T}}, x::BigInt) where {T<:IEEEFloat}
    return convert(DoubleFloat{T}, BigFloat(x))
end

Base.convert(::Type{DoubleFloat{T}}, x::DoubleFloat{DoubleFloat{T}}) where {T<:IEEEFloat} = HI(x)
Base.convert(::Type{DoubleFloat{DoubleFloat{T}}}, x::DoubleFloat{T}) where {T<:IEEEFloat} =
    DoubleFloat(x, DoubleFloat{T}(zero(T)))

Base.convert(::Type{T}, x::DoubleFloat{DoubleFloat{T}}) where {T<:IEEEFloat} = HI(HI(x))
Base.convert(::Type{DoubleFloat{DoubleFloat{T}}}, x::T) where {T<:IEEEFloat} =
    DoubleFloat(DoubleFloat{T}(x), DoubleFloat{T}(zero(T)))

Base.convert(::Type{DoubleFloat{T}}, x::Tuple{T,T}) where {T<:IEEEFloat} = unsafe_double(T, x[1], x[2])

Base.convert(::Type{Complex{Double64}}, x::T) where {T<:AbstractIrrational} = Complex(Double64(x))
Base.convert(::Type{Complex{Double32}}, x::T) where {T<:AbstractIrrational} = Complex(Double32(x))
Base.convert(::Type{Complex{Double16}}, x::T) where {T<:AbstractIrrational} = Complex(Double16(x))

Base.convert(::Type{DoubleFloat{T}}, x::Real) where {T<:IEEEFloat} = DoubleFloat{T}(BigFloat(x))
Base.convert(::Type{DoubleFloat{T}}, x::IEEEFloat) where {T<:IEEEFloat} = DoubleFloat{T}(x)
