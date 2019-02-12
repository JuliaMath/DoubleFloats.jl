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
    return Complex{DoubleFloat{T}}(sin_real(rea, ima), sin_imag(rea, ima))
end

function cos(x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat}
    rea, ima = real(x), imag(x)
    return Complex{DoubleFloat{T}}(cos_real(rea, ima), cos_imag(rea, ima))
end

function tan(x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat}
    rea, ima = real(x), imag(x)
    return Complex{DoubleFloat{T}}(tan_real(rea, ima), tan_imag(rea, ima))
end

function csc(x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat}
    rea, ima = real(x), imag(x)
    return Complex{DoubleFloat{T}}(csc_real(rea, ima), csc_imag(rea, ima))
end

function sec(x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat}
    rea, ima = real(x), imag(x)
    return Complex{DoubleFloat{T}}(sec_real(rea, ima), sec_imag(rea, ima))
end

function cot(x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat}
    rea, ima = real(x), imag(x)
    return Complex{DoubleFloat{T}}(cot_real(rea, ima), cot_imag(rea, ima))
end


function asin(x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat}
    rea, ima = real(x), imag(x)
    return Complex{DoubleFloat{T}}(asin_real(rea, ima), asin_imag(rea, ima))
end

function acos(x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat}
    rea, ima = real(x), imag(x)
    return Complex{DoubleFloat{T}}(acos_real(rea, ima), acos_imag(rea, ima))
end

function atan(x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat}
    rea, ima = real(x), imag(x)
    return Complex{DoubleFloat{T}}(atan_real(rea, ima), atan_imag(rea, ima))
end

function acsc(x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat}
    rea, ima = real(x), imag(x)
    return Complex{DoubleFloat{T}}(acsc_real(rea, ima), acsc_imag(rea, ima))
end

function asec(x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat}
    rea, ima = real(x), imag(x)
    return Complex{DoubleFloat{T}}(asec_real(rea, ima), asec_imag(rea, ima))
end

function acot(x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat}
    rea, ima = real(x), imag(x)
    return Complex{DoubleFloat{T}}(acot_real(rea, ima), acot_imag(rea, ima))
end


function sinh(x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat}
    rea, ima = real(x), imag(x)
    return Complex{DoubleFloat{T}}(sinh_real(rea, ima), sinh_imag(rea, ima))
end

function cosh(x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat}
    rea, ima = real(x), imag(x)
    return Complex{DoubleFloat{T}}(cosh_real(rea, ima), cosh_imag(rea, ima))
end

function tanh(x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat}
    rea, ima = real(x), imag(x)
    return Complex{DoubleFloat{T}}(tanh_real(rea, ima), tanh_imag(rea, ima))
end

function csch(x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat}
    rea, ima = real(x), imag(x)
    return Complex{DoubleFloat{T}}(csch_real(rea, ima), csch_imag(rea, ima))
end

function sech(x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat}
    rea, ima = real(x), imag(x)
    return Complex{DoubleFloat{T}}(sech_real(rea, ima), sech_imag(rea, ima))
end

function coth(x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat}
    rea, ima = real(x), imag(x)
    return Complex{DoubleFloat{T}}(coth_real(rea, ima), coth_imag(rea, ima))
end


function asinh(x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat}
    rea, ima = real(x), imag(x)
    return Complex{DoubleFloat{T}}(asinh_real(rea, ima), asinh_imag(rea, ima))
end

function acosh(x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat}
    rea, ima = real(x), imag(x)
    return Complex{DoubleFloat{T}}(acosh_real(rea, ima), acosh_imag(rea, ima))
end

function atanh(x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat}
    rea, ima = real(x), imag(x)
    return Complex{DoubleFloat{T}}(atanh_real(rea, ima), atanh_imag(rea, ima))
end

function acsch(x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat}
    rea, ima = real(x), imag(x)
    return Complex{DoubleFloat{T}}(acsch_real(rea, ima), acsch_imag(rea, ima))
end

function asech(x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat}
    rea, ima = real(x), imag(x)
    return Complex{DoubleFloat{T}}(asech_real(rea, ima), asech_imag(rea, ima))
end

function acoth(x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat}
    rea, ima = real(x), imag(x)
    return Complex{DoubleFloat{T}}(acoth_real(rea, ima), acoth_imag(rea, ima))
end



tan(x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat} = sin(x) / cos(x)
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

  
