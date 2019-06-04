@inline function reim(x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat}
    return x.re, x.im
end

@inline function csgn(r,i)
    HI(r) > 0 && return  1
    HI(r) < 0 && return -1
    return HI(i) > 0 ? 1 : -1
end

square(x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat} = x*x


sqrt(x::ComplexDF64) = ComplexDF64ComplexF128(sqrt, x)

# development from functions.wolfram.com

#=
Julia(evalc(Re(sqrt(r+i*sqrt(-1)))), optimize = true);
t1 = i ^ 2
t2 = r ^ 2
t4 = sqrt(t1 + t2)
t7 = sqrt(2) * sqrt(t4 + r) / 2
Julia(evalc(Im(sqrt(r+i*sqrt(-1)))), optimize = true);
Warning, type signature [complex] for function sqrt is not recognized
Warning, the function names {csgn} are not recognized in the target language
t3 = csgn(-1im * r + i)
t4 = i ^ 2
t5 = r ^ 2
t7 = sqrt(t4 + t5)
t11 = sqrt(2) * sqrt(t7 - r) * t3 / 2
=#
#=
function sqrt(x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat}
    rea, ima = reim(x)
    fourthroot = sqrt(hypot(rea, ima))
    halfatan = atan(ima, rea) * 0.5
    rea = fourthroot * cos(halfatan)
    ima = fourthroot * sin(halfatan)
    return Complex{DoubleFloat{T}}(rea, ima)
end
=#

#=
Julia(evalc(Re(exp(r+i*sqrt(-1)))), optimize = true);
t1 = exp(r)
t2 = cos(i)
t3 = t2 * t1
Julia(evalc(Im(exp(r+i*sqrt(-1)))), optimize = true);
t1 = exp(r)
t2 = sin(i)
t3 = t2 * t1
=#
function exp(x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat}
    rea, ima = reim(x)
    erea = exp(rea)
    realpart = erea * cos(ima)
    imagpart = erea * sin(ima)
    return Complex{DoubleFloat{T}}(realpart, imagpart)
end

#=

Julia(evalc(Re(log(r+i*sqrt(-1)))), optimize = true);
t1 = i ^ 2
t2 = r ^ 2
t4 = log(t1 + t2)
t5 = t4 / 2
Julia(evalc(Im(log(r+i*sqrt(-1)))), optimize = true);
t1 = atan2(i, r)
=#
function log(x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat}
    rea, ima = reim(x)
    realpart = log(square(rea) + square(ima)) * 0.5
    imagpart = atan(ima, rea)
    return Complex{DoubleFloat{T}}(realpart, imagpart)
end

#=
Julia(evalc(Re(sin(r+i*sqrt(-1)))), optimize = true);
t1 = sin(r)
t2 = cosh(i)
t3 = t2 * t1
Julia(evalc(Im(sin(r+i*sqrt(-1)))), optimize = true);
t1 = cos(r)
t2 = sinh(i)
t3 = t2 * t1
=#
function sin(x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat}
    rea, ima = reim(x)
    rea, ima = sin(rea) * cosh(ima), cos(rea) * sinh(ima)
    return Complex{DoubleFloat{T}}(rea, ima)
end

#=
Julia(evalc(Re(cos(r+i*sqrt(-1)))), optimize = true);
t1 = cos(r)
t2 = cosh(i)
t3 = t2 * t1
Julia(evalc(Im(cos(r+i*sqrt(-1)))), optimize = true);
t1 = sin(r)
t2 = sinh(i)
t4 = -t2 * t1
=#
function cos(x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat}
    rea, ima = reim(x)
    rea, ima = cos(rea) * cosh(ima), -sin(rea) * sinh(ima)
    return Complex{DoubleFloat{T}}(rea, ima)
end

#=
Julia(evalc(Re(tan(r+i*sqrt(-1)))), optimize = true);
t1 = sin(r)
t2 = cos(r)
t4 = t2 ^ 2
t5 = sinh(i)                        # real(x), t5=0
t6 = t5 ^ 2                         # real(x), t6=0
t9 = 0.1e1 / (t4 + t6) * t2 * t1    # real(x), 1 / t4 * t2 * t1 = t2*t1/t4
Julia(evalc(Im(tan(r+i*sqrt(-1)))), optimize = true);
t1 = sinh(i)
t2 = cosh(i)
t4 = cos(r)
t5 = t4 ^ 2
t6 = t1 ^ 2
t9 = 0.1e1 / (t5 + t6) * t2 * t1
=#
function tan(x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat}
    rea, ima = 2*real(x), 2*imag(x)
    den = cos(rea) + cosh(ima)
    rea = sin(rea) / den
    ima = sinh(ima) / den
    return Complex{DoubleFloat{T}}(rea, ima)
end

#=
Julia(evalc(Re(csc(r+i*sqrt(-1)))), optimize = true);
t1 = sin(r)
t2 = cosh(i)
t4 = t1 ^ 2
t5 = sinh(i)
t6 = t5 ^ 2
t9 = 0.1e1 / (t4 + t6) * t2 * t1
Julia(evalc(Im(csc(r+i*sqrt(-1)))), optimize = true);
t1 = cos(r)
t2 = sinh(i)
t4 = sin(r)
t5 = t4 ^ 2
t6 = t2 ^ 2
t10 = -0.1e1 / (t5 + t6) * t2 * t1
=#
function csc(x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat}
    rea, ima = reim(x)
    den = cos(2*rea) - cosh(2*ima)
    rea, ima = 2*(sin(rea)*cosh(ima)), 2*(cos(rea)*sinh(ima))
    rea = -rea / den 
    ima = ima / den
    return Complex{DoubleFloat{T}}(rea, ima)
end

#=
Julia(evalc(Re(sec(r+i*sqrt(-1)))), optimize = true);
t1 = cos(r)
t2 = cosh(i)
t4 = t1 ^ 2
t5 = sinh(i)
t6 = t5 ^ 2
t9 = 0.1e1 / (t4 + t6) * t2 * t1
Julia(evalc(Im(sec(r+i*sqrt(-1)))), optimize = true);
t1 = sin(r)
t2 = sinh(i)
t4 = cos(r)
t5 = t4 ^ 2
t6 = t2 ^ 2
t9 = 0.1e1 / (t5 + t6) * t2 * t1
=#
function sec(x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat}
    rea, ima = reim(x)
    den = cos(2*rea) + cosh(2*ima)
    rea, ima = 2*(cos(rea)*cosh(ima)), 2*(sin(rea)*sinh(ima))
    rea = rea / den 
    ima = ima / den
    return Complex{DoubleFloat{T}}(rea, ima)
end

#=
Julia(evalc(Re(cot(r+i*sqrt(-1)))), optimize = true);
t1 = sin(r)
t2 = cos(r)
t4 = t1 ^ 2
t5 = sinh(i)
t6 = t5 ^ 2
t9 = 0.1e1 / (t4 + t6) * t2 * t1
Julia(evalc(Im(cot(r+i*sqrt(-1)))), optimize = true);
t1 = sinh(i)
t2 = cosh(i)
t4 = sin(r)
t5 = t4 ^ 2
t6 = t1 ^ 2
t10 = -0.1e1 / (t5 + t6) * t2 * t1
=#
function cot(x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat}
    rea, ima = 2*real(x), 2*imag(x)
    den = cos(rea) - cosh(ima)
    rea = -sin(rea) / den
    ima = sinh(ima) / den
    return Complex{DoubleFloat{T}}(rea, ima)
end


#=
Julia(evalc(Re(sinh(r+i*sqrt(-1)))), optimize = true);
t1 = sinh(r)
t2 = cos(i)
t3 = t2 * t1
Julia(evalc(Im(sinh(r+i*sqrt(-1)))), optimize = true);
t1 = cosh(r)
t2 = sin(i)
t3 = t2 * t1
=#
function sinh(x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat}
    rea, ima = reim(x)
    rea, ima = sinh(rea) * cos(ima), cosh(rea) * sin(ima)
    return Complex{DoubleFloat{T}}(rea, ima)
end

#=
Julia(evalc(Re(cosh(r+i*sqrt(-1)))), optimize = true);
t1 = cosh(r)
t2 = cos(i)
t3 = t2 * t1
Julia(evalc(Im(cosh(r+i*sqrt(-1)))), optimize = true);
t1 = sinh(r)
t2 = sin(i)
t3 = t2 * t1
=#
function cosh(x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat}
    rea, ima = reim(x)
    rea, ima = cosh(rea) * cos(ima), sinh(rea) * sin(ima)
    return Complex{DoubleFloat{T}}(rea, ima)
end

#=
Julia(evalc(Re(tanh(r+i*sqrt(-1)))), optimize = true);
t1 = sinh(r)
t2 = cosh(r)
t4 = t1 ^ 2
t5 = cos(i)
t6 = t5 ^ 2
t9 = 0.1e1 / (t4 + t6) * t2 * t1
Julia(evalc(Im(tanh(r+i*sqrt(-1)))), optimize = true);
t1 = sin(i)
t2 = cos(i)
t4 = sinh(r)
t5 = t4 ^ 2
t6 = t2 ^ 2
t9 = 0.1e1 / (t5 + t6) * t2 * t1
=#
function tanh(x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat}
    rea, ima = 2*real(x), 2*imag(x)
    den = cosh(rea) + cos(ima)
    rea = sinh(rea) / den
    ima = sin(ima) / den
    return Complex{DoubleFloat{T}}(rea, ima)
end

#=
Julia(evalc(Re(csch(r+i*sqrt(-1)))), optimize = true);
t1 = sinh(r)
t2 = cos(i)
t4 = t1 ^ 2
t5 = sin(i)
t6 = t5 ^ 2
t9 = 0.1e1 / (t4 + t6) * t2 * t1
Julia(evalc(Im(csch(r+i*sqrt(-1)))), optimize = true);
t1 = cosh(r)
t2 = sin(i)
t4 = sinh(r)
t5 = t4 ^ 2
t6 = t2 ^ 2
=#
function csch(x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat}
    rea, ima = reim(x)
    den = cos(2*ima) - cosh(2*rea)
    rea, ima = 2*(sinh(rea)*cos(ima)), 2*(cosh(rea)*sin(ima))
    rea = -rea / den 
    ima = ima / den
    return Complex{DoubleFloat{T}}(rea, ima)
end

#=
Julia(evalc(Re(sech(r+i*sqrt(-1)))), optimize = true);
t1 = cos(i)
t2 = cosh(r)
t4 = sinh(r)
t5 = t4 ^ 2
t6 = t1 ^ 2
t9 = 0.1e1 / (t5 + t6) * t2 * t1
Julia(evalc(Im(sech(r+i*sqrt(-1)))), optimize = true);
t1 = sin(i)
t2 = sinh(r)
t4 = t2 ^ 2
t5 = cos(i)
t6 = t5 ^ 2
t10 = -0.1e1 / (t4 + t6) * t2 * t1
=#
function sech(x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat}
    rea, ima = reim(x)
    den = cos(2*ima) + cosh(2*rea)
    rea, ima = 2*(cos(ima)*cosh(rea)), 2*(sin(ima)*sinh(rea))
    rea = rea / den 
    ima = -ima / den
    return Complex{DoubleFloat{T}}(rea, ima)
end

#=
Julia(evalc(Re(coth(r+i*sqrt(-1)))), optimize = true);
t1 = sinh(r)
t2 = cosh(r)
t4 = t1 ^ 2
t5 = sin(i)
t6 = t5 ^ 2
t9 = 0.1e1 / (t4 + t6) * t2 * t1
Julia(evalc(Im(coth(r+i*sqrt(-1)))), optimize = true);
t1 = sin(i)
t2 = cos(i)
t4 = sinh(r)
t5 = t4 ^ 2
t6 = t1 ^ 2
t10 = -0.1e1 / (t5 + t6) * t2 * t1
=#
function coth(x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat}
    rea, ima = 2*real(x), 2*imag(x)
    den = cos(ima) - cosh(rea)
    rea = -sinh(rea) / den
    ima = sin(ima) / den
    return Complex{DoubleFloat{T}}(rea, ima)
end

#=
Julia(evalc(Re(arcsin(r+i*sqrt(-1)))), optimize = true);
t2 = (r + 1) ^ 2
t3 = i ^ 2
t5 = sqrt(t2 + t3)
t7 = (r - 1) ^ 2
t9 = sqrt(t7 + t3)
t11 = asin(-t5 / 2 + t9 / 2)
t12 = -t11
Julia(evalc(Im(arcsin(r+i*sqrt(-1)))), optimize = true);
Warning, type signature [complex] for function sqrt is not recognized
Warning, the function names {csgn} are not recognized in the target language
t3 = csgn(-1im * r + i)
t5 = (r + 1) ^ 2
t6 = i ^ 2
t8 = sqrt(t5 + t6)
t11 = (r - 1) ^ 2
t13 = sqrt(t11 + t6)
t18 = sqrt((t8 + t13) ^ 2 / 4 - 1)
t20 = log(t8 / 2 + t13 / 2 + t18)
t21 = t20 * t3
=#
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

#=
Julia(evalc(Re(arccos(r+i*sqrt(-1)))), optimize = true);
t2 = (r + 1) ^ 2
t3 = i ^ 2
t5 = sqrt(t2 + t3)
t7 = (r - 1) ^ 2
t9 = sqrt(t7 + t3)
t11 = acos(-t5 / 2 + t9 / 2)
t12 = pi - t11
Julia(evalc(Im(arccos(r+i*sqrt(-1)))), optimize = true);
Warning, type signature [complex] for function sqrt is not recognized
Warning, the function names {csgn} are not recognized in the target language
t3 = csgn(-1im * r + i)
t5 = (r + 1) ^ 2
t6 = i ^ 2
t8 = sqrt(t5 + t6)
t11 = (r - 1) ^ 2
t13 = sqrt(t11 + t6)
t18 = sqrt((t8 + t13) ^ 2 / 4 - 1)
t20 = log(t8 / 2 + t13 / 2 + t18)
t22 = -t20 * t3
=#
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

#=
Julia(evalc(Re(arctan(r+i*sqrt(-1)))), optimize = true);
t2 = atan2(r, 1 - i)
t4 = atan2(-r, i + 1)
t6 = t2 / 2 - t4 / 2
Julia(evalc(Im(arctan(r+i*sqrt(-1)))), optimize = true);
t1 = r ^ 2
t3 = (i + 1) ^ 2
t6 = (i - 1) ^ 2
t10 = log(1 / (t1 + t6) * (t1 + t3))
t11 = t10 / 4
=#
function atan(x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat}
    rea, ima = reim(x)
    ima2 = square(ima)
    rea2 = square(rea)
    realpart = 0.5*(atan(2*rea/(1-rea2-ima2)) + (pi1o2(DoubleFloat{T})*(sign(rea2+ima2-1)+1)) * sign(rea))
    imagpart = (log(square(ima + 1) + rea2) - log(rea2 + square(1 - ima))) * 0.25      
    return Complex{DoubleFloat{T}}(realpart, imagpart)
end

#=
Julia(evalc(Re(arccsc(r+i*sqrt(-1)))), optimize = true);
t1 = i ^ 2
t2 = r ^ 2
t3 = t1 + t2
t5 = 0.1e1 / t3 * r
t7 = (t5 + 1) ^ 2
t8 = t3 ^ 2
t10 = 0.1e1 / t8 * t1
t12 = sqrt(t7 + t10)
t14 = (t5 - 1) ^ 2
t16 = sqrt(t14 + t10)
t18 = asin(-t12 / 2 + t16 / 2)
t19 = -t18
Julia(evalc(Im(arccsc(r+i*sqrt(-1)))), optimize = true);
Warning, type signature [complex] for function sqrt is not recognized
Warning, the function names {csgn} are not recognized in the target language
t2 = csgn(1im * r + i)
t3 = i ^ 2
t4 = r ^ 2
t5 = t3 + t4
t7 = 0.1e1 / t5 * r
t9 = (t7 + 1) ^ 2
t10 = t5 ^ 2
t12 = 0.1e1 / t10 * t3
t14 = sqrt(t9 + t12)
t17 = (t7 - 1) ^ 2
t19 = sqrt(t17 + t12)
t24 = sqrt((t14 + t19) ^ 2 / 4 - 1)
t26 = log(t14 / 2 + t19 / 2 + t24)
t28 = -t26 * t2
=#
function acsc(z::Complex{DoubleFloat{T}}) where {T<:IEEEFloat}
    return asin(inv(z))
end

#=
Julia(evalc(Re(arcsec(r+i*sqrt(-1)))), optimize = true);
t1 = i ^ 2
t2 = r ^ 2
t3 = t1 + t2
t5 = 0.1e1 / t3 * r
t7 = (t5 + 1) ^ 2
t8 = t3 ^ 2
t10 = 0.1e1 / t8 * t1
t12 = sqrt(t7 + t10)
t14 = (t5 - 1) ^ 2
t16 = sqrt(t14 + t10)
t18 = acos(-t12 / 2 + t16 / 2)
t19 = pi - t18
Julia(evalc(Im(arcsec(r+i*sqrt(-1)))), optimize = true);
Warning, type signature [complex] for function sqrt is not recognized
Warning, the function names {csgn} are not recognized in the target language
t2 = csgn(1im * r + i)
t3 = i ^ 2
t4 = r ^ 2
t5 = t3 + t4
t7 = 0.1e1 / t5 * r
t9 = (t7 + 1) ^ 2
t10 = t5 ^ 2
t12 = 0.1e1 / t10 * t3
t14 = sqrt(t9 + t12)
t17 = (t7 - 1) ^ 2
t19 = sqrt(t17 + t12)
t24 = sqrt((t14 + t19) ^ 2 / 4 - 1)
t26 = log(t14 / 2 + t19 / 2 + t24)
t27 = t26 * t2
=#
function asec(z::Complex{DoubleFloat{T}}) where {T<:IEEEFloat}
    return acos(inv(z))
end

#=
Julia(evalc(Re(arccot(r+i*sqrt(-1)))), optimize = true);
t2 = atan2(r, 1 - i)
t4 = atan2(-r, i + 1)
t6 = pi / 2 - t2 / 2 + t4 / 2
Julia(evalc(Im(arccot(r+i*sqrt(-1)))), optimize = true);
t1 = r ^ 2
t3 = (i + 1) ^ 2
t6 = (i - 1) ^ 2
t10 = log(1 / (t1 + t6) * (t1 + t3))
t12 = -t10 / 4
=#
function acot(x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat}
    rea, ima = reim(x)
    ima2 = square(ima)
    rea2 = square(rea)
    den = rea2 + ima2
    realpart = (atanxy((1 + (ima/den)), (rea/den)) - atanxy((1 - (ima/den)), -(rea/den))) * 0.5 
    imagpart = (log((square(ima - 1) + rea2)/den) - log((square(ima +1) + rea2)/den)) * 0.25      
    return Complex{DoubleFloat{T}}(realpart, imagpart)
end

#=
Julia(evalc(Re(arcsinh(r+i*sqrt(-1)))), optimize = true);
Warning, type signature [complex] for function sqrt is not recognized
Warning, the function names {csgn} are not recognized in the target language
t2 = csgn(r + 1im * i)
t3 = r ^ 2
t5 = (i + 1) ^ 2
t7 = sqrt(t3 + t5)
t10 = (i - 1) ^ 2
t12 = sqrt(t3 + t10)
t17 = sqrt((t7 + t12) ^ 2 / 4 - 1)
t19 = log(t7 / 2 + t12 / 2 + t17)
t20 = t19 * t2
Julia(evalc(Im(arcsinh(r+i*sqrt(-1)))), optimize = true);
t1 = r ^ 2
t3 = (i + 1) ^ 2
t5 = sqrt(t1 + t3)
t7 = (i - 1) ^ 2
t9 = sqrt(t1 + t7)
t11 = asin(-t5 / 2 + t9 / 2)
t12 = -t11
=#

function asinh(x::Complex{DoubleFloat{T}}) where {T}
    r, i = real(x), imag(x)
    signbit(r) && return - asinh(-x)
    r2 = r*r
    ip1sqr = (i + 1)^2
    sqrta  = sqrt(r2 + ip1sqr)
    im1sqr = (i - 1)^2
    sqrtb  = sqrt(r2 + im1sqr)
    t1 = sqrt((sqrta + sqrtb)^2 / 4 - 1)
    t2 = log(sqrta / 2 + sqrtb / 2 + t1)
    r = t2 * csgn(real(r + 1im * i), imag(r+1im * i))
    t3 = asin(-sqrta / 2 + sqrtb / 2)
    i  = - t3
    return Complex{DoubleFloat{T}}(r, i)
end

#=

Julia(evalc(Re(arccosh(r+i*sqrt(-1)))), optimize = true);
Warning, type signature [complex] for function sqrt is not recognized
Warning, the function names {csgn} are not recognized in the target language
t1 = -1im * r
t3 = csgn(t1 + 1im + i)
t5 = csgn(t1 + i)
t8 = (r + 1) ^ 2
t9 = i ^ 2
t11 = sqrt(t8 + t9)
t14 = (r - 1) ^ 2
t16 = sqrt(t14 + t9)
t21 = sqrt((t11 + t16) ^ 2 / 4 - 1)
t23 = log(t11 / 2 + t16 / 2 + t21)
t24 = t23 * t5 * t3
Julia(evalc(Im(arccosh(r+i*sqrt(-1)))), optimize = true);
Warning, type signature [complex] for function sqrt is not recognized
Warning, the function names {csgn} are not recognized in the target language
t3 = csgn(-1im * r + 1im + i)
t5 = (r + 1) ^ 2
t6 = i ^ 2
t8 = sqrt(t5 + t6)
t10 = (r - 1) ^ 2
t12 = sqrt(t10 + t6)
t14 = acos(-t8 / 2 + t12 / 2)
t16 = (pi - t14) * t3
=#
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

#=
Julia(evalc(Re(arctanh(r+i*sqrt(-1)))), optimize = true);
t2 = (r + 1) ^ 2
t3 = i ^ 2
t6 = (r - 1) ^ 2
t10 = log(1 / (t6 + t3) * (t2 + t3))
t11 = t10 / 4
Julia(evalc(Im(arctanh(r+i*sqrt(-1)))), optimize = true);
t2 = atan2(i, r + 1)
t4 = atan2(-i, 1 - r)
t6 = t2 / 2 - t4 / 2
=#

function atanh(x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat}
    rea, ima = reim(x)
    ima2 = square(ima)
    rea2 = square(rea)
    realpart = (log(square(rea + 1) + ima2) - log(square(rea) - 2*rea + ima2 + 1)) * 0.25 
    imagpart = 0.5*(atan(2*ima/(1-rea2-ima2)) + (pi1o2(DoubleFloat{T})*(sign(rea2+ima2-1)+1)) * sign(ima))
    return Complex{DoubleFloat{T}}(realpart, imagpart)
end

#=

Julia(evalc(Re(arccsch(r+i*sqrt(-1)))), optimize = true);
Warning, type signature [complex] for function sqrt is not recognized
Warning, the function names {csgn} are not recognized in the target language
t2 = csgn(1im * i - r)
t3 = r ^ 2
t4 = i ^ 2
t5 = t4 + t3
t6 = t5 ^ 2
t8 = 0.1e1 / t6 * t3
t10 = 0.1e1 / t5 * i
t12 = (-t10 + 1) ^ 2
t14 = sqrt(t8 + t12)
t17 = (-t10 - 1) ^ 2
t19 = sqrt(t8 + t17)
t24 = sqrt((t14 + t19) ^ 2 / 4 - 1)
t26 = log(t14 / 2 + t19 / 2 + t24)
t28 = -t26 * t2
Julia(evalc(Im(arccsch(r+i*sqrt(-1)))), optimize = true);
t1 = r ^ 2
t2 = i ^ 2
t3 = t2 + t1
t4 = t3 ^ 2
t6 = 0.1e1 / t4 * t1
t8 = 0.1e1 / t3 * i
t10 = (-t8 + 1) ^ 2
t12 = sqrt(t10 + t6)
t14 = (-t8 - 1) ^ 2
t16 = sqrt(t6 + t14)
t18 = asin(-t12 / 2 + t16 / 2)
t19 = -t18
=#
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

#=

Julia(evalc(Re(arcsech(r+i*sqrt(-1)))), optimize = true);
Warning, type signature [complex] for function sqrt is not recognized
Warning, the function names {csgn} are not recognized in the target language
t1 = i ^ 2
t2 = r ^ 2
t5 = csgn(1im * t1 + 1im * t2 + -1im * r - i)
t7 = csgn(1im * r + i)
t9 = t1 + t2
t11 = 0.1e1 / t9 * r
t13 = (t11 + 1) ^ 2
t14 = t9 ^ 2
t16 = 0.1e1 / t14 * t1
t18 = sqrt(t13 + t16)
t21 = (t11 - 1) ^ 2
t23 = sqrt(t21 + t16)
t28 = sqrt((t18 + t23) ^ 2 / 4 - 1)
t30 = log(t18 / 2 + t23 / 2 + t28)
t32 = -t30 * t7 * t5
Julia(evalc(Im(arcsech(r+i*sqrt(-1)))), optimize = true);
Warning, type signature [complex] for function sqrt is not recognized
Warning, the function names {csgn} are not recognized in the target language
t1 = i ^ 2
t2 = r ^ 2
t5 = csgn(1im * t1 + 1im * t2 + -1im * r - i)
t6 = t1 + t2
t8 = 0.1e1 / t6 * r
t10 = (t8 + 1) ^ 2
t11 = t6 ^ 2
t13 = 0.1e1 / t11 * t1
t15 = sqrt(t10 + t13)
t17 = (t8 - 1) ^ 2
t19 = sqrt(t17 + t13)
t21 = acos(-t15 / 2 + t19 / 2)
t23 = (pi - t21) * t5
=#
function asech(x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat}
    return log((sqrt(1-square(x))+1)/x)
end

#=
Julia(evalc(Re(arccoth(r+i*sqrt(-1)))), optimize = true);
t2 = (r + 1) ^ 2
t3 = i ^ 2
t6 = (r - 1) ^ 2
t10 = log(1 / (t6 + t3) * (t2 + t3))
t11 = t10 / 4
Julia(evalc(Im(arccoth(r+i*sqrt(-1)))), optimize = true);
t2 = atan2(i, r + 1)
t4 = atan2(i, r - 1)
t6 = t2 / 2 - t4 / 2
=#
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

