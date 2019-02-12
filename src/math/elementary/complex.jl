@inline function reim(x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat}
     return x.re, x.im
end

square(x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat} = x*x

# development from functions.wolfram.com

function sqrt(x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat}
    rea, ima = reim(x)
    fourthroot = sqrt(hypot(rea, ima))
    halfatan = atan(rea, ima) * 0.5
    rea = fourthroot * cos(halfatan)
    ima = fourthroot * sin(halfatan)
    return Complex{DoubleFloat{T}}(rea, ima)
end

function exp(x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat}
    rea, ima = reim(x)
    erea = exp(rea)
    rea = erea * cos(ima)
    ima = erea * sin(ima)
    return Complex{DoubleFloat{T}}(rea, ima)
end

function log(x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat}
    rea, ima = reim(x)
    rea = log(square(rea) + square(ima)) * 0.5
    ima = atan(real(x), ima)
    return Complex{DoubleFloat{T}}(rea, ima)
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
    return Complex{DoubleFloat{T}}(atan_real(rea, ima), atan_imag(rea, ima))
end

# http://functions.wolfram.com/ElementaryFunctions/ArcTan/19/01/
#  (1/2)*(atan((2* x)/(1 - x^2 - y^2)) + (1/2)*(sign(x^2 + y^2 - 1) + 1)*pi*sign(x))
function atan_real(x::DoubleFloat{T}, y::DoubleFloat{T}) where {T<:IEEEFloat}
    x2 = square(x)
    y2 = square(y)
    a = 2*x / (1 - (x2 + y2))
    b = pio2(DoubleFloat{T}) * (sign(x2 + y2 - 1) + 1) * sign(x)
    result = (atan(a) + b) * 0.5
    return result
end

# http://functions.wolfram.com/ElementaryFunctions/ArcTan/19/02/
# (1/4)*log((x^2 + (y + 1)^2)/(x^2 + (1 - y)^2))
function atan_imag(x::DoubleFloat{T}, y::DoubleFloat{T}) where {T<:IEEEFloat}
    x2 = square(x)
    num = x2 + square(1 + y)
    den = x2 + square(1 - y)
    result = num / den
    result = log(result) * 0.25
    return result
end

function acsc(z::Complex{DoubleFloat{T}}) where {T<:IEEEFloat}
    return asin(inv(z))
end

function asec(z::Complex{DoubleFloat{T}}) where {T<:IEEEFloat}
    return acos(inv(z))
end

function acot(x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat}
    rea, ima = reim(x)
    return Complex{DoubleFloat{T}}(acot_real(rea, ima), acot_imag(rea, ima))
end

# http://functions.wolfram.com/ElementaryFunctions/ArcTan/19/01/
#  (1/2)*(atan((2* x)/(1 - x^2 - y^2)) + (1/2)*(sign(x^2 + y^2 - 1) + 1)*pi*sign(x))
#  (1/2)*(atan((2* x)/(x^2 + y^2 - 1)) + (Pi/4) Sign[x] (1 - Sign[x^2 + y^2 - 1])
function acot_real(x::DoubleFloat{T}, y::DoubleFloat{T}) where {T<:IEEEFloat}
    x2 = square(x)
    y2 = square(y)
    a = 2*x / ((x2 + y2) - 1)
    b = pio2(DoubleFloat{T}) * (1 - sign(x2 + y2 - 1)) * sign(x)
    result = (atan(a) + b) * 0.5
    return result
end

# http://functions.wolfram.com/ElementaryFunctions/ArcTan/19/02/
# (1/4)*log((x^2 + (y + 1)^2)/(x^2 + (1 - y)^2))
# (1/4)*log( (x^2 + (y+1)^2)/(x^2 + (y - 1)^2))
function acot_imag(x::DoubleFloat{T}, y::DoubleFloat{T}) where {T<:IEEEFloat}
    x2 = square(x)
    num = x2 + square(1 + y)
    den = x2 + square(y - 1)
    result = num / den
    result = log(result) * 0.25
    return result
end


function asinh(x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat}
    rea, ima = reim(x)
    t1 = square(rea)
    t2 = square(t1)
    t3 = square(ima)
    t5 = square(t3 - 1) ^ 2
    t10 = (t2 + t5 + 2 * (t3 + 1) * t1)
    t10 = sqrt(sqrt(t10))
    t14 = arctanxy(-t3 + t1 + 1, 2 * ima * rea)
    t15 = t14 / 2
    t16 = cos(t15)
    t18 = t16 * t10 + rea
    t19 = square(t18)
    t20 = sin(t15)
    t22 = t20 * t10 + ima
    t23 = square(t22)
    t25 = log(t19 + t23) / 2
    t27 = arctanxy(t18, t22)
    return Complex{DoubleFloat{T}}(t25, t27)
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
    t19 = pio1(DoubleFloat{T}) - t19
    return Complex{DoubleFloat{T}}(t17, t19)
end

function atanh(x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat}
    rea, ima = reim(x)
    t2 = square(rea + 1)
    t3 = square(ima)
    t6 = square(1 - rea)
    t10 = inv((t6 + t3) * (t2 + t3))
    t10 = log(t10)/4
    t12 = square(rea)
    t17 = arctan(2 / (-t3 - t12 + 1) * ima)
    t17 = (t17*0.5) + pio2(DoubleFloat{T})
    return Complex{DoubleFloat{T}}(t10, t17)
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
    rea, ima = reim(x)
    t1 = square(ima)
    t2 = square(rea)
    t4 = inv(t1 + t2)
    t5 = 2 * rea
    t7 = sqrt(t1 + t2 - t5 + 1)
    t8 = rea + 1
    t9 = square(t8)
    t11 = sqrt(t9 + t1)
    t13 = t1 + t2 + t5 + 1
    t14 = sqrt(t13)
    t17 = sqrt(inv(t14 * t7))
    t20 = inv(t13)
    t24 = arctanxy(-t20 * (t1 + t2 - 1), -2 * t20 * ima)
    t25 = t24 / 2
    t26 = cos(t25)
    t28 = t17 * ima
    t29 = sin(t25)
    t30 = t29 * t28
    t34 = (2 * t26 * t17 * t8 + t11 * t7 - 2 * t30 + 1)
    t34 = log(t32 * t4) / 2
    t37 = t17 * (t1 + t2 + rea)
    t45 = arctanxy((t26 * t37 + rea + t30) * t4, -(t26 * t28 - t29 * t37 + ima) * t4)
    return Complex{DoubleFloat{T}}(t34, t45)
end

# above is done


