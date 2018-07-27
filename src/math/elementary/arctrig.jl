
const k_pio2 = Double64(1.5707963267948966, 6.123233995736766e-17)


function atan(x::DoubleFloat{T}) where {T<:AbstractFloat}
   signbit(x) && return -atan(abs(x))
   y = DoubleFloat{T}(atan(x.hi))
   s, c = sin(y), cos(y)
   c2 = square(c)
   t = s/c
   z = y - (t - x)*c2 # z - (tan(x)-x)*(cos(x)^2)
   s, c = sin(z), cos(z)
   t = s/c
   z = z - (t - x)*c2 # z - (tan(x)-x)*(cos(x)^2)
   return z
end

function atan(y::DoubleFloat{T}, x::DoubleFloat{T}) where {T<:AbstractFloat}
   atanyx = atan(y/x) 
   if x > 0 
      atanyx
   elseif x < 0
      if y >= 0
         atanyx + T(pi)
      else
         atanyx - T(pi)
      end
   elseif y > 0
       T(pi)/2
   elseif y < 0
      -T(pi)/2
   else
      zero(T)
   end
end

function asin(x::DoubleFloat{T}) where {T<:AbstractFloat}
   signbit(x) && return -asin(abs(x))
   abs(x) > 1.0 && throw(DomainError("$x"))
   y = x
   y = y / (1.0 + sqrt(1.0 - square(y)))
   z = atan(y)
   return DoubleFloat{T}(z.hi+z.hi, z.lo+z.lo)
end

function acos(x::DoubleFloat{T}) where {T<:AbstractFloat}
   signbit(x) && return DoubleFloat{T}(onepi - acos(abs(x)))
   abs(x) > 1.0 && throw(DomainError("$x"))
   y = x
   y = sqrt(1.0 - square(y)) / (1.0 + y)
   z = atan(y)
   return DoubleFloat{T}(z.hi+z.hi, z.lo+z.lo)
end

acsc(x::DoubleFloat{T}) where {T<:AbstractFloat} = asin(inv(x))
asec(x::DoubleFloat{T}) where {T<:AbstractFloat} = acos(inv(x))

function acot(x::DoubleFloat{T}) where {T<:AbstractFloat}
   signbit(x) && return DoubleFloat{T}(onepi - acot(abs(x)))
   iszero(x) && return k_pio2
   z = k_pio2 - atan(abs(x))
   if signbit(x.hi)
      z = -z
   end
   return z
end
