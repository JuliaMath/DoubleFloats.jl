@inline function reim(x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat}
     return x.re, x.im
end

square(x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat} = x*x

# development from functions.wolfram.com

function sqrt(x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat}
    rea, ima = reim(x)
    fourthroot = sqrt(hypot(rea, ima))
    halfatan = atan(ima, rea) * 0.5
    rea = fourthroot * cos(halfatan)
    ima = fourthroot * sin(halfatan)
    return Complex{DoubleFloat{T}}(rea, ima)
end

function exp(x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat}
    rea, ima = reim(x)
    erea = exp(rea)
    realpart = erea * cos(ima)
    imagpart = erea * sin(ima)
    return Complex{DoubleFloat{T}}(realpart, imagpart)
end

function log(x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat}
    rea, ima = reim(x)
    realpart = log(square(rea) + square(ima)) * 0.5
    imagpart = atan(ima, rea)
    return Complex{DoubleFloat{T}}(realpart, imagpart)
end

function sin(x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat}
    rea, ima = reim(x)
    rea, ima = sin(rea) * cosh(ima), cos(rea) * sinh(ima)
    return Complex{DoubleFloat{T}}(rea, ima)
end

function cos(x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat}
    rea, ima = reim(x)
    rea, ima = cos(rea) * cosh(ima), -sin(rea) * sinh(ima)
    return Complex{DoubleFloat{T}}(rea, ima)
end

function tan(x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat}
    rea, ima = 2*real(x), 2*imag(x)
    den = cos(rea) + cosh(ima)
    rea = sin(rea) / den
    ima = sinh(ima) / den
    return Complex{DoubleFloat{T}}(rea, ima)
end

function csc(x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat}
    rea, ima = reim(x)
    den = cos(2*rea) - cosh(2*ima)
    rea, ima = 2*(sin(rea)*cosh(ima)), 2*(cos(rea)*sinh(ima))
    rea = -rea / den 
    ima = ima / den
    return Complex{DoubleFloat{T}}(rea, ima)
end

function sec(x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat}
    rea, ima = reim(x)
    den = cos(2*rea) + cosh(2*ima)
    rea, ima = 2*(cos(rea)*cosh(ima)), 2*(sin(rea)*sinh(ima))
    rea = rea / den 
    ima = ima / den
    return Complex{DoubleFloat{T}}(rea, ima)
end

function cot(x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat}
    rea, ima = 2*real(x), 2*imag(x)
    den = cos(rea) - cosh(ima)
    rea = -sin(rea) / den
    ima = sinh(ima) / den
    return Complex{DoubleFloat{T}}(rea, ima)
end



function sinh(x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat}
    rea, ima = reim(x)
    rea, ima = sinh(rea) * cos(ima), cosh(rea) * sin(ima)
    return Complex{DoubleFloat{T}}(rea, ima)
end

function cosh(x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat}
    rea, ima = reim(x)
    rea, ima = cosh(rea) * cos(ima), sinh(rea) * sin(ima)
    return Complex{DoubleFloat{T}}(rea, ima)
end

function tanh(x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat}
    rea, ima = 2*real(x), 2*imag(x)
    den = cosh(rea) + cos(ima)
    rea = sinh(rea) / den
    ima = sin(ima) / den
    return Complex{DoubleFloat{T}}(rea, ima)
end

function csch(x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat}
    rea, ima = reim(x)
    den = cos(2*ima) - cosh(2*rea)
    rea, ima = 2*(sinh(rea)*cos(ima)), 2*(cosh(rea)*sin(ima))
    rea = -rea / den 
    ima = ima / den
    return Complex{DoubleFloat{T}}(rea, ima)
end

function sech(x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat}
    rea, ima = reim(x)
    den = cos(2*ima) + cosh(2*rea)
    rea, ima = 2*(cos(ima)*cosh(rea)), 2*(sin(ima)*sinh(rea))
    rea = rea / den 
    ima = -ima / den
    return Complex{DoubleFloat{T}}(rea, ima)
end

function coth(x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat}
    rea, ima = 2*real(x), 2*imag(x)
    den = cos(ima) - cosh(rea)
    rea = -sinh(rea) / den
    ima = sin(ima) / den
    return Complex{DoubleFloat{T}}(rea, ima)
end


function asin(x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat}
    rea, ima = reim(x)
    xp1sq = square(rea + 1)
    xm1sq = square(rea - 1)
    ysq   = square(ima)
    xp1py = sqrt(xp1sq + ysq)
    xm1py = sqrt(xm1sq + ysq)
    rea = asin((xp1py - xm1py) * 0.5)
    x = (xm1py + xp1py) * 0.5
    ima = sign(ima) * log(x + sqrt(square(x) - 1))
   return Complex{DoubleFloat{T}}(rea, ima)
end

function acos(x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat}
    rea, ima = reim(x)
    xp1sq = square(rea + 1)
    xm1sq = square(rea - 1)
    ysq   = square(ima)
    xp1py = sqrt(xp1sq + ysq)
    xm1py = sqrt(xm1sq + ysq)
    rea = acos((xp1py - xm1py) * 0.5)
    x = (xm1py + xp1py) * 0.5
    ima = -sign(ima) * log(x + sqrt(square(x) - 1))
   return Complex{DoubleFloat{T}}(rea, ima)
end

function atan(x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat}
    rea, ima = reim(x)
    ima2 = square(ima)
    rea2 = square(rea)
    realpart = 0.5*(atan(2*rea/(1-rea2-ima2)) + (pi1o2(DoubleFloat{T})*(sign(rea2+ima2-1)+1)) * sign(rea))
    imagpart = (log(square(ima + 1) + rea2) - log(rea2 + square(1 - ima))) * 0.25      
    return Complex{DoubleFloat{T}}(realpart, imagpart)
end

function acsc(z::Complex{DoubleFloat{T}}) where {T<:IEEEFloat}
    return asin(inv(z))
end

function asec(z::Complex{DoubleFloat{T}}) where {T<:IEEEFloat}
    return acos(inv(z))
end

function acot(x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat}
    rea, ima = reim(x)
    ima2 = square(ima)
    rea2 = square(rea)
    den = rea2 + ima2
    realpart = (atanxy((1 + (ima/den)), (rea/den)) - atanxy((1 - (ima/den)), -(rea/den))) * 0.5 
    imagpart = (log((square(ima - 1) + rea2)/den) - log((square(ima +1) + rea2)/den)) * 0.25      
    return Complex{DoubleFloat{T}}(realpart, imagpart)
end

function asinh(x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat}
    return log( x + sqrt(square(x) + 1) )
end

function acosh(x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat}
    rea, ima = reim(x)
    t2 = (rea - 1) ^ 2
    t3 = ima ^ 2
    t5 = sqrt(t2 + t3)
    t8 = (rea + 1) ^ 2
    t10 = sqrt(t8 + t3)
    t15 = sqrt((t5 + t10) ^ 2 / 4 - 1)
    t17 = log(t5 / 2 + t10 / 2 + t15)
    t19 = acos(-t10 / 2 + t5 / 2)
    t19 = pi1o1(DoubleFloat{T}) - t19
    return Complex{DoubleFloat{T}}(t17, t19)
end

function atanh(x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat}
    rea, ima = reim(x)
    ima2 = square(ima)
    rea2 = square(rea)
    realpart = (log(square(rea + 1) + ima2) - log(square(rea) - 2*rea + ima2 + 1)) * 0.25 
    imagpart = 0.5*(atan(2*ima/(1-rea2-ima2)) + (pi1o2(DoubleFloat{T})*(sign(rea2+ima2-1)+1)) * sign(ima))
    return Complex{DoubleFloat{T}}(realpart, imagpart)
end

function acsch(z::Complex{DoubleFloat{T}}) where {T<:IEEEFloat}
    rea, ima = reim(z)
    t1 = square(ima)
    t2 = square(rea)
    t3 = t1 + t2
    t4 = inv(t3)
    t6 = square(t2)
    t8 = square(t1 - 1)
    t13 = square(t3)
    t14 = inv(t13)
    t16 = t14 * (t6 + t8 + 2 * (t1 + 1) * t2)
    t16 = sqrt(sqrt(t16))
    t23 = atanxy(1 + t14 * (-t1 + t2), -2 * t14 * ima * rea)
    t24 = t23 / 2
    t25 = cos(t24)
    t28 = square(t4 * rea + t25 * t16)
    t30 = sin(t24)
    t33 = square(t4 * ima - t30 * t16)
    t35 = log(t28 + t33)/2
    t37 = t16 * t3
    t44 = atanxy((t25 * t37 + rea) * t4, (t30 * t37 - ima) * t4)
    return Complex{DoubleFloat{T}}(t35, t44)
end

function asech(x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat}
    return log((sqrt(1-square(x))+1)/x)
end

function acoth(x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat}
    rea, ima = reim(x)
    rea2 = square(rea)
    ima2 = square(ima)
    den = rea2 + ima2
    num = den + 1
    num1 = num + 2*rea
    num2 = num - 2*rea
    realpart = (log(num1/den) - log(num2/den)) * 0.25
    num1 = rea / den
    num2 = ima / den
    imagpart = (atanxy(num1 + 1, -num2) - atanxy(1 - num1, num2)) * 0.5
    return Complex{DoubleFloat{T}}(realpart, imagpart)
end

