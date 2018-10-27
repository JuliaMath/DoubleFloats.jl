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



function fma(xhi::T, xlo::T, yhi::T, ylo::T, zhi::T, zlo::T) where {T<:AbstractFloat}
   chi, c1 = two_prod(xhi, yhi)
   t0 = xlo * ylo
   t1 = fma(xhi, ylo, t0)
   c2 = fma(xlo, yhi, t1)
   c3 = c1 + c2
   dhi, dlo = two_hilo_sum(chi, c3)

   shi, slo = two_sum(zhi, dhi)
   thi, tlo = two_sum(zlo, dlo)
   c = slo + thi
   vhi, vlo = two_hilo_sum(shi, c)
   w = tlo + vlo
   hi, lo = two_hilo_sum(vhi, w)
   return DoubleFloat{T}(hi, lo)
end

@inline function fma(x::DoubleFloat{T}, y::DoubleFloat{T}, z::DoubleFloat{T}) where {T<:AbstractFloat}
   return fma(x.hi, x.lo, y.hi, y.lo, z.hi, z.lo)
end

@inline function fma(x::DoubleFloat{T}, y::DoubleFloat{T}, z::Tuple{T,T}) where {T<:AbstractFloat}
   return fma(x.hi, x.lo, y.hi, y.lo, z[1], z[2])
end
@inline function fma(x::DoubleFloat{T}, y::Tuple{T,T}, z::DoubleFloat{T}) where {T<:AbstractFloat}
   return fma(x.hi, x.lo, y[1], y[2], z.hi, z.lo)
end
@inline function fma(x::Tuple{T,T}, y::DoubleFloat{T}, z::DoubleFloat{T}) where {T<:AbstractFloat}
   return fma(x[1], x[2], y.hi, y.lo, z.hi, z.lo)
end
@inline function fma(x::DoubleFloat{T}, y::Tuple{T,T}, z::Tuple{T,T}) where {T<:AbstractFloat}
   return fma(x.hi, x.lo, y[1], y[2], z[1], z[2])
end
@inline function fma(x::Tuple{T,T}, y::Tuple{T,T}, z::DoubleFloat{T}) where {T<:AbstractFloat}
   return fma(x[1], x[2], y[1], y[2], z.hi, z.lo)
end
@inline function fma(x::Tuple{T,T}, y::DoubleFloat{T}, z::Tuple{T,T}) where {T<:AbstractFloat}
   return fma(x[1], x[2], y.hi, y.lo, z[1], z[2])
end
@inline function fma(x::Tuple{T,T}, y::Tuple{T,T}, z::Tuple{T,T}) where {T<:AbstractFloat}
   return fma(x[1], x[2], y[1], y[2], z[1], z[2])
end


function muladd(xhi::T, xlo::T, yhi::T, ylo::T, zhi::T, zlo::T) where {T<:AbstractFloat}
   chi, c1 = two_prod(xhi, yhi)
   t0 = xlo * ylo
   c2 = fma(xlo, yhi, t0)
   c3 = c1 + c2
   dhi, dlo = two_hilo_sum(chi, c3)

   shi, slo = two_sum(zhi, dhi)
   thi, tlo = two_sum(zlo, dlo)
   c = slo + thi
   vhi, vlo = two_hilo_sum(shi, c)
   w = tlo + vlo
   hi, lo = two_hilo_sum(vhi, w)
   return DoubleFloat{T}(hi, lo)
end

@inline function muladd(x::DoubleFloat{T}, y::DoubleFloat{T}, z::DoubleFloat{T}) where {T<:AbstractFloat}
   return muladd(x.hi, x.lo, y.hi, y.lo, z.hi, z.lo)
end


@inline function muladd(x::DoubleFloat{T}, y::DoubleFloat{T}, z::Tuple{T,T}) where {T<:AbstractFloat}
   return muladd(x.hi, x.lo, y.hi, y.lo, z[1], z[2])
end
@inline function muladd(x::DoubleFloat{T}, y::Tuple{T,T}, z::DoubleFloat{T}) where {T<:AbstractFloat}
   return muladd(x.hi, x.lo, y[1], y[2], z.hi, z.lo)
end
@inline function muladd(x::Tuple{T,T}, y::DoubleFloat{T}, z::DoubleFloat{T}) where {T<:AbstractFloat}
   return muladd(x[1], x[2], y.hi, y.lo, z.hi, z.lo)
end
@inline function muladd(x::DoubleFloat{T}, y::Tuple{T,T}, z::Tuple{T,T}) where {T<:AbstractFloat}
   return muladd(x.hi, x.lo, y[1], y[2], z[1], z[2])
end
@inline function muladd(x::Tuple{T,T}, y::Tuple{T,T}, z::DoubleFloat{T}) where {T<:AbstractFloat}
   return muladd(x[1], x[2], y[1], y[2], z.hi, z.lo)
end
@inline function muladd(x::Tuple{T,T}, y::DoubleFloat{T}, z::Tuple{T,T}) where {T<:AbstractFloat}
   return muladd(x[1], x[2], y.hi, y.lo, z[1], z[2])
end
@inline function muladd(x::Tuple{T,T}, y::Tuple{T,T}, z::Tuple{T,T}) where {T<:AbstractFloat}
   return muladd(x[1], x[2], y[1], y[2], z[1], z[2])
end
