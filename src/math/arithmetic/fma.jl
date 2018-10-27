import Base: muladd, fma

"""
    two_sum(a, b)
Computes `hi = fl(a+b)` and `lo = err(a+b)`.
"""
@inline function two_sum(a::T, b::T) where {T<:AbstractFloat}
    hi = a + b
    a1 = hi - b
    b1 = hi - a1
    lo = (a - a1) + (b - b1)
    return hi, lo
end


"""
    two_hilo_sum(a, b)
*unchecked* requirement `|a| ≥ |b|`
Computes `s = fl(a+b)` and `e = err(a+b)`.
"""
@inline function two_hilo_sum(a::T, b::T) where {T<:AbstractFloat}
    s = a + b
    e = b - (s - a)
    return s, e
end

@inline function two_prod(a::T, b::T) where {T<:AbstractFloat}
    s = a * b
    t = fma(a, b, -s)
    return s, t
end



function fma(xxₕ::T, xxₗ::T, yyₕ::T, yyₗ::T, zzₕ::T, zzₗ::T) where {T<:AbstractFloat}
   cₕᵢ, c1 = two_prod(xxₕ, yyₕ)
   t0 = xxₗ * yyₗ
   t1 = fma(xxₕ, yyₗ, t0)
   c2 = fma(xxₗ, yyₕ, t1)
   c3 = c1 + c2
   zₕ, zₗ = two_hilo_sum(cₕ, c3)
   
   sₕ, sₗ = two_sum(zzₕ, zₕ)
   tₕ, tₗ = two_sum(zzₗ, zₗ)
   c = sₗ + tₕ
   vₕ, vₗ = two_hilo_sum(sₕ, c)
   w = tₗ + vₗₒ
   zₕ, zₗ = two_hilo_sum(vₕ, w)
   return zₕ, zₗ
end

@inline function fma(x::DoubleFloat{T}, y::DoubleFloat{T}, z::DoubleFloat{T}) where {T<:AbstractFloat}
   return fma(x.hi, x.lo, y.hi, y.lo, z.hi, z.lo)
end

function muladd(xxₕ::T, xxₗ::T, yyₕ::T, yyₗ::T, zzₕ::T, zzₗ::T) where {T<:AbstractFloat}
   cₕ, c1 = two_prod(xxₕ, yyₕ)
   t0 = xxₗ * yyₗ
   c2 = fma(xxₗ, yyₕ, t0)
   c3 = c1 + c2
   zₕ, zₗ = two_hilo_sum(cₕ, c3)
   
   sₕ, sₗ = two_sum(zzₕ, zₕ)
   tₕ, tₗ = two_sum(zzₗ, zₗ)
   c = sₗ + tₕ
   vₕ, vₗ = two_hilo_sum(sₕ, c)
   w = tₗ + vₗ
   zₕ, zₗ = two_hilo_sum(vₕ, w)
   return zₕ, zₗ
end

@inline function muladd(x::DoubleFloat{T}, y::DoubleFloat{T}, z::DoubleFloat{T}) where {T<:AbstractFloat}
   return muladd(x.hi, x.lo, y.hi, y.lo, z.hi, z.lo)
end

