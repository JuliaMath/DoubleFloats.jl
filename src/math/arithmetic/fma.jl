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



function fma(xxₕᵢ::T, xxₗₒ::T, yyₕᵢ::T, yyₗₒ::T, zzₕᵢ::T, zzₗₒ::T) where {T<:AbstractFloat}
   cₕᵢ, c1 = two_prod(xxₕᵢ, yyₕᵢ)
   t0 = xxₗₒ * yyₗₒ
   t1 = fma(xₕᵢ, yₗₒ, t0)
   c2 = fma(xₗₒ, yₕᵢ, t1)
   c3 = c1 + c2
   zₕᵢ, zₗₒ = two_hilo_sum(cₕᵢ, c3)
   
   sₕᵢ, sₗₒ = two_sum(zzₕᵢ, zₕᵢ)
   tₕᵢ, tₗₒ = two_sum(zzₗₒ, zₗₒ)
   c = sₗₒ + tₕᵢ
   vₕᵢ, vₗₒ = two_hilo_sum(sₕᵢ, c)
   w = tₗₒ + vₗₒ
   zₕᵢ, zₗₒ = two_hilo_sum(vₕᵢ, w)
   return zₕᵢ, zₗₒ
end

@inline function fma(x::DoubleFloat{T}, y::DoubleFloat{T}, z::DoubleFloat{T}) where {T<:AbstractFloat}
   return fma(x.hi, x.lo, y.hi, y.lo, z.hi, z.lo)
end

function muladd(xxₕᵢ::T, xxₗₒ::T, yyₕᵢ::T, yyₗₒ::T, zzₕᵢ::T, zzₗₒ::T) where {T<:AbstractFloat}
   cₕᵢ, c1 = two_prod(xxₕᵢ, yyₕᵢ)
   t0 = xxₗₒ * yyₗₒ
   c2 = fma(xxₗₒ, yyₕᵢ, t0)
   c3 = c1 + c2
   zₕᵢ, zₗₒ = two_hilo_sum(cₕᵢ, c3)
   
   sₕᵢ, sₗₒ = two_sum(zzₕᵢ, zₕᵢ)
   tₕᵢ, tₗₒ = two_sum(zzₗₒ, zₗₒ)
   c = sₗₒ + tₕᵢ
   vₕᵢ, vₗₒ = two_hilo_sum(sₕᵢ, c)
   w = tₗₒ + vₗₒ
   zₕᵢ, zₗₒ = two_hilo_sum(vₕᵢ, w)
   return zₕᵢ, zₗₒ
end

@inline function muladd(x::DoubleFloat{T}, y::DoubleFloat{T}, z::DoubleFloat{T}) where {T<:AbstractFloat}
   return muladd(x.hi, x.lo, y.hi, y.lo, z.hi, z.lo)
end

