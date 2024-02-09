#=
struct MultiFloat{T,N} <: AbstractFloat
    _limbs::NTuple{N,T}
end
=#

# This function is needed to work around the following SIMD bug:
# https://github.com/eschnett/SIMD.jl/issues/115
@inline _ntuple_equal(x::NTuple{2,Float64}, y::NTuple{2,Float64}) = (x[1] === y[1]) && (x[2] === y[2])
@inline _ntuple_equal(x::NTuple{N,Vec{M,T}}, y::NTuple{N,Vec{M,T}}) where {N,M,T} = all(all.(x .== y))

const Tuple2 = NTuple{2, Float64}

struct Double64 <: AbstractFloat
    hilo::NTuple{2,Float64}
end

Double64() = Double64((0.0, 0.0))
Double64(hi::Float64) = Double64((hi, 0.0))

Base.zero(::Type{Double64}) = Double64((0.0, 0.0))
Base.one(::Type{Double64}) = Double64((1.0, 0.0))

Base.length(::Type{Double64}) = 2
Base.getindex(x::Double64, idx::Integer) = getindex(x, x.hilo[idx])

#

@inline function fast_twosum(a::T, b::T) where {T}
    sum = a + b
    b_prime = sum - a
    b_err = b - b_prime
    return (sum, b_err)
end

@inline function fast_twodiff(a::T, b::T) where {T}
    diff = a - b
    b_prime = a - diff
    b_err = b_prime - b
    return (diff, b_err)
end

@inline function twosum(a::T, b::T) where {T}
    sum = a + b
    a_prime = sum - b
    b_prime = sum - a_prime
    a_err = a - a_prime
    b_err = b - b_prime
    err = a_err + b_err
    return (sum, err)
end

@inline function twodiff(a::T, b::T) where {T}
    diff = a - b
    a_prime = diff + b
    b_prime = a_prime - diff
    a_err = a - a_prime
    b_err = b - b_prime
    err = a_err - b_err
    return (diff, err)
end

@inline function twoprod(a::T, b::T) where {T}
    prod = a * b
    err = fma(a, b, -prod)
    return (prod, err)
end

@inline function renormalize(x::Float64, y::Float64)
    return( twosum(x, y) )
end
@inline function renormalize(a::Tuple2)
    return( twosum(a[1], a[2]) )
end
@inline function renormalize(a::Double64)
    Double64(renormalize(a.hilo))
end

