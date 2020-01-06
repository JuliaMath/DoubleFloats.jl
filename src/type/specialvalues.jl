zero(::Type{DoubleFloat{T}}) where {T<:IEEEFloat} = DoubleFloat{T}(zero(T), zero(T))
one(::Type{DoubleFloat{T}}) where {T<:IEEEFloat} = DoubleFloat{T}(one(T), zero(T))

nan(::Type{DoubleFloat{T}}) where {T<:IEEEFloat} = DoubleFloat{T}(T(NaN), T(NaN))
inf(::Type{DoubleFloat{T}}) where {T<:IEEEFloat} = DoubleFloat{T}(T(Inf), T(NaN))
posinf(::Type{DoubleFloat{T}}) where {T<:IEEEFloat} = DoubleFloat{T}(T(Inf), T(NaN))
neginf(::Type{DoubleFloat{T}}) where {T<:IEEEFloat} = DoubleFloat{T}(T(-Inf), T(NaN))

typemax(::Type{DoubleFloat{T}}) where {T<:IEEEFloat} = DoubleFloat{T}(typemax(T))
typemin(::Type{DoubleFloat{T}}) where {T<:IEEEFloat} = DoubleFloat{T}(typemin(T))

floatmin(::Type{DoubleFloat{T}}) where {T<:IEEEFloat} = DoubleFloat{T}(floatmin(T))

floatmax(::Type{DoubleFloat{Float64}}) = Double64(ldexp(Float64(0.9999999999999999), 1024), ldexp(Float64(0.9999999999999999), 970))
floatmax(::Type{DoubleFloat{Float32}}) = Double32(ldexp(Float32(0.99999994f0), 128), ldexp(Float32(0.99999994f0), 103))
floatmax(::Type{DoubleFloat{Float16}}) = Double16(ldexp(Float16(0.9995),16), ldexp(Float16(0.9996),4))

maxintfloat(::Type{DoubleFloat{Float64}}) = DoubleFloat{Float64}(ldexp(0.5, 107), ldexp(0.5, 54))
maxintfloat(::Type{DoubleFloat{Float32}}) = DoubleFloat{Float32}(ldexp(0.5f0, 49), ldexp(0.5f0, 25))
maxintfloat(::Type{DoubleFloat{Float16}}) = DoubleFloat{Float16}(65519.0)
