#=
julia-0.7> x=0.5; y=atan(x); z=Double(y); z - (tan(z)-x)*(cos(z)*cos(z))
Double(0.4636476090008061, 2.2698777452961687e-17)

julia-0.7> t=atan(BigFloat(x));thi=Float64(t);tlo=Float64(t-thi);thi,tlo
(0.4636476090008061, 2.2698777452961687e-17)
=#

function atan(x::Double{T,Accuracy}) where {T<:AbstractFloat}
   y = Double{T,Accuracy}(atan(x.hi))
   s, c = sin(y), cos(y)
   t = s/c
   z = y - (t - x)*(square(c)) # z - (tan(x)-x)*(cos(x)^2)
   return z
end

function atan(x::Double{T,Performance}) where {T<:AbstractFloat}
   y = Double{T,Accuracy}(atan(x.hi))
   s, c = sin(y), cos(y)
   t = s/c
   z = y - (t - x)*(square(c)) # z - (tan(x)-x)*(cos(x)^2)
   return z
end

#=
http://mathworld.wolfram.com/InverseTangent.html cites Acton 1990
=#
#=
function atan(x::T) where {T<:AbstractFloat}
    return atan(x)
end

function atan(x::Double{T,Accuracy}) where {T<:AbstractFloat}
    b = one(Double{T,Accuracy})
    a = inv(sqrt(b+square(x)))
    result = x * a
    while abs(a) < abs(b)
        a = (a + b) / 2
        b = sqrt(a * b)
    end

    result = result * inv(a)
    return result
end

function atan(x::Double{T,Performance}) where {T<:AbstractFloat}
    result = arctan(Double{T,Accuracy}(x))
    return Double(Performance, HILO(result))
end
=#
