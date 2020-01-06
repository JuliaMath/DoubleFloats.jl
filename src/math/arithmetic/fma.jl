function fma(xhi::T, xlo::T, yhi::T, ylo::T, zhi::T, zlo::T) where {T<:IEEEFloat}
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

@inline function fma(x::DoubleFloat{T}, y::DoubleFloat{T}, z::DoubleFloat{T}) where {T<:IEEEFloat}
   return fma(x.hi, x.lo, y.hi, y.lo, z.hi, z.lo)
end

function fma(x::T, y::T, zhi::T, zlo::T) where {T<:IEEEFloat}
   chi, c1 = two_prod(x, y)
   shi, slo = two_sum(zhi, chi)
   thi, tlo = two_sum(zlo, c1)
   c = slo + thi
   vhi, vlo = two_hilo_sum(shi, c)
   w = tlo + vlo
   hi, lo = two_hilo_sum(vhi, w)
   return DoubleFloat{T}(hi, lo)
end

@inline function fma(x::T, y::T, z::DoubleFloat{T}) where {T<:IEEEFloat}
   return fma(x, y, z.hi, z.lo)
end

function fma(xhi::T, xlo::T, yhi::T, ylo::T, z::T) where {T<:IEEEFloat}
   chi, c1 = two_prod(xhi, yhi)
   t0 = xlo * ylo
   t1 = fma(xhi, ylo, t0)
   c2 = fma(xlo, yhi, t1)
   c3 = c1 + c2
   dhi, dlo = two_hilo_sum(chi, c3)
   shi, slo = two_sum(z, dhi)
   c = slo + dlo
   hi, lo = two_hilo_sum(shi, c)
   return DoubleFloat{T}(hi, lo)
end

@inline function fma(x::DoubleFloat{T}, y::DoubleFloat{T}, z::T) where {T<:IEEEFloat}
   return fma(x.hi, x.lo, y.hi, y.lo, z)
end

@inline function fma(x::DoubleFloat{T}, y::DoubleFloat{T}, z::Tuple{T,T}) where {T<:IEEEFloat}
   return fma(x.hi, x.lo, y.hi, y.lo, z[1], z[2])
end
@inline function fma(x::DoubleFloat{T}, y::Tuple{T,T}, z::DoubleFloat{T}) where {T<:IEEEFloat}
   return fma(x.hi, x.lo, y[1], y[2], z.hi, z.lo)
end
@inline function fma(x::Tuple{T,T}, y::DoubleFloat{T}, z::DoubleFloat{T}) where {T<:IEEEFloat}
   return fma(x[1], x[2], y.hi, y.lo, z.hi, z.lo)
end
@inline function fma(x::DoubleFloat{T}, y::Tuple{T,T}, z::Tuple{T,T}) where {T<:IEEEFloat}
   return fma(x.hi, x.lo, y[1], y[2], z[1], z[2])
end
@inline function fma(x::Tuple{T,T}, y::Tuple{T,T}, z::DoubleFloat{T}) where {T<:IEEEFloat}
   return fma(x[1], x[2], y[1], y[2], z.hi, z.lo)
end
@inline function fma(x::Tuple{T,T}, y::DoubleFloat{T}, z::Tuple{T,T}) where {T<:IEEEFloat}
   return fma(x[1], x[2], y.hi, y.lo, z[1], z[2])
end
@inline function fma(x::Tuple{T,T}, y::Tuple{T,T}, z::Tuple{T,T}) where {T<:IEEEFloat}
   return fma(x[1], x[2], y[1], y[2], z[1], z[2])
end

#@inline muladd(xhi::T, xlo::T, yhi::T, ylo::T, zhi::T, zlo::T) where {T<:IEEEFloat} = fma(xhi, xlo, yhi, ylo, zhi, zlo)

@inline function muladd(x::DoubleFloat{T}, y::DoubleFloat{T}, z::DoubleFloat{T}) where {T<:IEEEFloat}
   return x*y + z
end

@inline function muladd(x::T, y::T, z::DoubleFloat{T}) where {T<:IEEEFloat}
   return DoubleFloat{T}(x)*y + z
end

@inline function muladd(x::DoubleFloat{T}, y::DoubleFloat{T}, z::T) where {T<:IEEEFloat}
   return x*y + z
end
#=
@inline function muladd(x::DoubleFloat{T}, y::DoubleFloat{T}, z::Tuple{T,T}) where {T<:IEEEFloat}
   return muladd(x.hi, x.lo, y.hi, y.lo, z[1], z[2])
end
@inline function muladd(x::DoubleFloat{T}, y::Tuple{T,T}, z::DoubleFloat{T}) where {T<:IEEEFloat}
   return muladd(x.hi, x.lo, y[1], y[2], z.hi, z.lo)
end
@inline function muladd(x::Tuple{T,T}, y::DoubleFloat{T}, z::DoubleFloat{T}) where {T<:IEEEFloat}
   return muladd(x[1], x[2], y.hi, y.lo, z.hi, z.lo)
end
@inline function muladd(x::DoubleFloat{T}, y::Tuple{T,T}, z::Tuple{T,T}) where {T<:IEEEFloat}
   return muladd(x.hi, x.lo, y[1], y[2], z[1], z[2])
end
@inline function muladd(x::Tuple{T,T}, y::Tuple{T,T}, z::DoubleFloat{T}) where {T<:IEEEFloat}
   return muladd(x[1], x[2], y[1], y[2], z.hi, z.lo)
end
@inline function muladd(x::Tuple{T,T}, y::DoubleFloat{T}, z::Tuple{T,T}) where {T<:IEEEFloat}
   return muladd(x[1], x[2], y.hi, y.lo, z[1], z[2])
end
@inline function muladd(x::Tuple{T,T}, y::Tuple{T,T}, z::Tuple{T,T}) where {T<:IEEEFloat}
   return muladd(x[1], x[2], y[1], y[2], z[1], z[2])
end
=#
