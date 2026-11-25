Base.zero(::Type{DoubleFloat{T}}) where {T<:IEEEFloat} = unsafe_double(T, zero(T), zero(T))
Base.one(::Type{DoubleFloat{T}}) where {T<:IEEEFloat} = unsafe_double(T, one(T), zero(T))

nan(::Type{DoubleFloat{T}}) where {T<:IEEEFloat} = unsafe_double(T, T(NaN), T(NaN))
inf(::Type{DoubleFloat{T}}) where {T<:IEEEFloat} = unsafe_double(T, T(Inf), T(Inf))
posinf(::Type{DoubleFloat{T}}) where {T<:IEEEFloat} = unsafe_double(T, T(Inf), T(Inf))
neginf(::Type{DoubleFloat{T}}) where {T<:IEEEFloat} = unsafe_double(T, T(-Inf), T(-Inf))

Base.typemax(::Type{DoubleFloat{T}}) where {T<:IEEEFloat} = DoubleFloat{T}(typemax(T))
Base.typemin(::Type{DoubleFloat{T}}) where {T<:IEEEFloat} = DoubleFloat{T}(typemin(T))

Base.floatmin(::Type{DoubleFloat{T}}) where {T<:IEEEFloat} = DoubleFloat{T}(floatmin(T))

Base.floatmax(::Type{DoubleFloat{Float64}}) =
    unsafe_double(Float64, ldexp(Float64(0.9999999999999999), 1024), ldexp(Float64(0.9999999999999999), 970))
Base.floatmax(::Type{DoubleFloat{Float32}}) =
    unsafe_double(Float32, ldexp(Float32(0.99999994f0), 128), ldexp(Float32(0.99999994f0), 103))
Base.floatmax(::Type{DoubleFloat{Float16}}) =
    unsafe_double(Float16, ldexp(Float16(0.9995), 16), ldexp(Float16(0.9996), 4))

Base.maxintfloat(::Type{DoubleFloat{Float64}}) = unsafe_double(Float64, ldexp(0.5, 107), ldexp(0.5, 54))
Base.maxintfloat(::Type{DoubleFloat{Float32}}) = unsafe_double(Float32, ldexp(0.5f0, 49), ldexp(0.5f0, 25))
Base.maxintfloat(::Type{DoubleFloat{Float16}}) = DoubleFloat{Float16}(65519.0)
