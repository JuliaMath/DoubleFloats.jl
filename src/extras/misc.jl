#=
     sqrt(eps(Float64)) == ldexp(0.5, -25) ~ 1.5e-8 
     isapprox here uses ldexp(0.5, -30) ~ 1.0e-9 ,   so the system default (sqrt(eps(T))) is ~32x less sensitive 5bits
                        ldexp(0.5, -31) ~ 2.3e-10,                                           ~64x less sensitive 6bits 
                                                                                                  (32.5 sig bits must match)

=#
releps(::Type{Float64}) = ldexp(0.5, -31)
releps(::Type{Float32}) = ldexp(inv(sqrt(2.0f0)), -17)
releps(::Type{Double64}) = ldexp(0.5, -62)
releps(::Type{Double32}) = ldexp(inv(sqrt(2.0f0)), -34)

function Base.isapprox(x::DoubleFloat{T}, y::Real; atol::Real=0.0, rtol::Real=Base.rtoldefault(HI(x),y,atol), nans::Bool=false) where {T<:IEEEFloat}
    return isapprox(x, DoubleFloat{T}(y), atol=atol, rtol=rtol, nans=nans)
end
function Base.isapprox(x::Real, y::DoubleFloat{T}; atol::Real=0.0, rtol::Real=Base.rtoldefault(x,HI(y),atol), nans::Bool=false) where {T<:IEEEFloat}
    return isapprox(DoubleFloat{T}(x), y, atol=atol, rtol=rtol, nans=nans)
end
function Base.isapprox(x::DoubleFloat{T}, y::DoubleFloat{T}; atol::Real=0.0, rtol::Real=Base.rtoldefault(HI(x),HI(y),atol), nans::Bool=false) where {T<:IEEEFloat}
    HI(x) === HI(y) || (isfinite(x) && isfinite(y) && abs(x-y) <= max(max(1.0e-32, atol), rtol*max(abs(x), abs(y)))) || (nans && isnan(x) && isnan(y))
end
Base.isapprox(x::DoubleFloat{T}, y::DoubleFloat{F}; atol::Real=0.0, rtol::Real=Base.rtoldefault(HI(x),HI(y),atol), nans::Bool=false) where {T<:IEEEFloat, F<:IEEEFloat} =
    isapprox(promote(x, y)..., atol=atol, rtol=rtol, nans=nans, norm=norm)

function Base.lerpi(j::Integer, d::Integer, a::DoubleFloat{T}, b::DoubleFloat{T}) where {T}
    t = DoubleFloat{T}(j)/d
    a = fma(-t, a, a)
    return fma(t, b, a)
end

function Base.clamp(x::DoubleFloat{T}, lo::DoubleFloat{T}, hi::DoubleFloat{T}) where {T}
     lo <= x <= hi && return x
     lo <= x && return hi
     return lo
end
function Base.clamp(x::DoubleFloat{T}, lo::T, hi::T) where {T}
     lo <= x <= hi && return x
     lo <= x && return hi
     return lo
end
function Base.clamp(x::T, lo::DoubleFloat{T}, hi::DoubleFloat{T}) where {T}
     lo <= x <= hi && return x
     lo <= x && return hi
     return lo
end

abs2(x::DoubleFloat{T}) where {T} =
    let absx = abs(x)
        absx * absx
    end

# for compatibility with old or unrevised outside linalg functions
function Base.:(+)(v::Vector{DoubleFloat{T}}, x::T) where {T}
    return v .+ x
end
function Base.:(-)(v::Vector{DoubleFloat{T}}, x::T) where {T}
    return v .- x
end
function Base.:(+)(m::Matrix{DoubleFloat{T}}, x::T) where {T}
    return m .+ x
end
function Base.:(-)(m::Matrix{DoubleFloat{T}}, x::T) where {T}
    return m .- x
end

# for getting fast floatmin2, used in Givens rotations in LinearAlgebra
# these values were computed with the existing code saved
# floatmin2(::Type{T}) where {T} = (twopar = 2one(T); twopar^trunc(Integer,log(floatmin(T)/eps(T))/log(twopar)/twopar))
LinearAlgebra.floatmin2(::Type{Double64}) = Double64(reinterpret(Float64, 0x2350000000000000), 0.0)
LinearAlgebra.floatmin2(::Type{Double32}) = Double32(reinterpret(Float32, 0x2c000000), 0.0f0)
