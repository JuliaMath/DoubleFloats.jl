#=
julia-0.7> x=0.5; y=atan(x); z=Double(y); z - (tan(z)-x)*(cos(z)*cos(z))
Double(0.4636476090008061, 2.2698777452961687e-17)

julia-0.7> t=atan(BigFloat(x));thi=Float64(t);tlo=Float64(t-thi);thi,tlo
(0.4636476090008061, 2.2698777452961687e-17)
=#

const k_pio2 = Double(1.5707963267948966, 6.123233995736766e-17)


function atan(x::Double{T,Accuracy}) where {T<:AbstractFloat}
   y = Double(Accuracy, atan(x.hi))
   s, c = sin(y), cos(y)
   c2 = square(c)
   t = s/c
   z = y - (t - x)*c2 # z - (tan(x)-x)*(cos(x)^2)
   s, c = sin(z), cos(z)
   t = s/c
   z = z - (t - x)*c2 # z - (tan(x)-x)*(cos(x)^2)
   return z
end

function atan(x::Double{T,Performance}) where {T<:AbstractFloat}
   y = Double(Performance, atan(x.hi))
   s, c = sin(y), cos(y)
   t = s/c
   z = y - (t - x)*square(c) # z - (tan(x)-x)*(cos(x)^2)
   return z
end


function asin(x::Double{T,Accuracy}) where {T<:AbstractFloat}
   abs(x) > 1.0 && throw(DomainError("$x"))
   y = x
   y = y / (1.0 + sqrt(1.0 - square(y)))
   z = atan(y)
   return Double(Accuracy, z.hi+z.hi, z.lo+z.lo)
end

function asin(x::Double{T,Performance}) where {T<:AbstractFloat}
   abs(x) > 1.0 && throw(DomainError("$x"))
   y = Double(Performance, asin(x.hi))
   s,c = sin(y), cos(y)
   z = y - (s - x)/c
   return z
end

function acos(x::Double{T,Accuracy}) where {T<:AbstractFloat}
   abs(x) > 1.0 && throw(DomainError("$x"))
   y = x
   y = sqrt(1.0 - square(y)) / (1.0 + y)
   z = atan(y)
   return Double(Accuracy, z.hi+z.hi, z.lo+z.lo)
end

function acos(x::Double{T,Performance}) where {T<:AbstractFloat}
     abs(x) > 1.0 && throw(DomainError("$x"))
     y = Double(Performance, acos(x.hi))
     s,c = sin(y), cos(y)
     z = y + (c - x)/s
     return z
end

acsc(x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis} = asin(inv(x))
asec(x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis} = acos(inv(x))

function acot(x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
   iszero(x) && return k_pio2
   z = k_pio2 - atan(abs(x))
   if signbit(x.hi)
      z = -z
   end
   return z
end
