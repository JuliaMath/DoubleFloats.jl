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
    ima = atan(rea, ima)
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
    im1 = zero(DoubleFloat{T}) + im
    return -(im1 * log((im1/z) + sqrt(1 - inv(z^2))))
end

function asec(z::Complex{DoubleFloat{T}}) where {T<:IEEEFloat}
    im1 = zero(DoubleFloat{T}) + im
    p = pio2(DoubleFloat{T})
    return p + (im1 * log((im1/z) + sqrt(1 - inv(z^2))))
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

function asech(x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat}
   invx = inv(x)
   result = sqrt(invx + 1) * sqrt(invx - 1) + invx
   result = log(result)
   return result
end

# above is done


