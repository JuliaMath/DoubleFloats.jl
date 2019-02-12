# development from functions.wolfram.com

function sqrt(x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat}
    rea, ima = real(x), imag(x)
    fourthroot = sqrt(hypot(rea, ima))
    halfatan = atan(rea, ima) * 0.5
    rea = fourthroot * cos(halfatan)
    ima = fourthroot * sin(halfatan)
    return Complex{DoubleFloat{T}}(rea, ima)
end

function exp(x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat}
    rea, ima = real(x), imag(x)
    erea = exp(rea)
    rea = erea * cos(ima)
    ima = erea * sin(ima)
    return Complex{DoubleFloat{T}}(rea, ima)
end

function log(x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat}
    rea, ima = real(x), imag(x)
    rea = log(square(x) + square(y)) * 0.5
    ima = atan(rea, ima)
    return Complex{DoubleFloat{T}}(rea, ima)
end

function sin(x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat}
    rea, ima = real(x), imag(x)
    rea, ima = sin(rea) * cosh(ima), cos(rea) * sinh(ima)
    return Complex{DoubleFloat{T}}(rea, ima)
end

function cos(x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat}
    rea, ima = real(x), imag(x)
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
    rea, ima = real(x), imag(x)
    den = cos(2*rea) - cosh(2*ima)
    rea, ima = 2*(sin(rea)*cosh(ima)), 2*(cos(rea)*sinh(ima))
    rea = -rea / den 
    ima = ima / den
    return Complex{DoubleFloat{T}}(rea, ima)
end

function sec(x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat}
    rea, ima = real(x), imag(x)
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





tanh(x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat} = sinh(x) / cosh(x)

function atan(x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat}
    rea, ima = real(x), imag(x)
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
