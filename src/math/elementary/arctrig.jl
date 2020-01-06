for F in (:asin, :acos, :atan, :acsc, :asec, :acot)
    @eval begin
      $F(x::Double64) = Double64Float128($F, x)
      $F(x::Double32) = Double32Float128($F, x)
      $F(x::Double16) = Double16Float128($F, x)
    end
end

atan(y::Double64, x::Double64) = Double64(atan(Quadmath.Float128(y), Quadmath.Float128(x)))
atan(y::Double32, x::Double32) = Double32(atan(Quadmath.Float128(y), Quadmath.Float128(x)))
atan(y::Double16, x::Double16) = Double16(atan(Quadmath.Float128(y), Quadmath.Float128(x)))

#=
const k_pio2 = Double64(1.5707963267948966, 6.123233995736766e-17)


function atan(x::DoubleFloat{T}) where {T<:IEEEFloat}
   signbit(x) && return -atan(abs(x))
   isinf(x) && return copysign(DoubleFloat{T}(pi)/2, x)
   iszero(x) && return x
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

function atan(y::DoubleFloat{T}, x::DoubleFloat{T}) where {T<:IEEEFloat}
   iszero(y) && iszero(x) && return x
   iszero(x) && return copysign(pi1o2(DoubleFloat{T}), y)
   iszero(y) && return signbit(x) ? pi1o1(DoubleFloat{T}) : zero(DoubleFloat{T})
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

function asin(x::DoubleFloat{T}) where {T<:IEEEFloat}
   (abs(x) > 1.0 || isinf(x)) && throw(DomainError("$x"))
   signbit(x) && return -asin(abs(x))
   y = x
   y = y / (1.0 + sqrt(1.0 - square(y)))
   z = atan(y)
   return DoubleFloat{T}(z.hi+z.hi, z.lo+z.lo)
end

function acos(x::DoubleFloat{T}) where {T<:IEEEFloat}
   (abs(x) > 1.0 || isinf(x)) && throw(DomainError("$x"))
   signbit(x) && return DoubleFloat{T}(onepi - acos(abs(x)))
   y = x
   y = sqrt(1.0 - square(y)) / (1.0 + y)
   z = atan(y)
   return DoubleFloat{T}(z.hi+z.hi, z.lo+z.lo)
end

function acsc(x::DoubleFloat{T}) where {T<:IEEEFloat}
    isinf(x) && return copysign(zero(DoubleFloat{T}), x)
    return asin(inv(x))
end

function asec(x::DoubleFloat{T}) where {T<:IEEEFloat}
   isinf(x) && return DoubleFloat{T}(halfpi)
   return acos(inv(x))
end

function acot(x::DoubleFloat{T}) where {T<:IEEEFloat}
   isinf(x) && return copysign(zero(DoubleFloat{T}), x)
   signbit(x) && return DoubleFloat{T}(onepi - acot(abs(x)))
   iszero(x) && return k_pio2
   z = k_pio2 - atan(abs(x))
   if signbit(x.hi)
      z = -z
   end
   return z
end
=#
