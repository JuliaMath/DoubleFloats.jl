const twopi  = DoubleF64(6.283185307179586, 2.4492935982947064e-16)
const onepi  = DoubleF64(3.141592653589793, 1.2246467991473532e-16)
const halfpi = DoubleF64(1.5707963267948966, 6.123233995736766e-17)
const qrtrpi = DoubleF64(0.7853981633974483, 3.061616997868383e-17)


#=
     sin(a) from the Taylor series.
     Assumes |a| <= pi/32.
=#
function sin_taylor(a::DoubleF64)
    iszero(a) && return(a)

    x = -square(a)
    r = a
    for i = 3:2:nused_inv_fact
        r = r * x
        t = r * inv_fact[i]
        a = a + t
    end

    return a
end


#=
   1 - x^2/2! + x^4/4! - x^6/6! + x^8/8! ...
=#
function cos_taylor(a::DoubleF64)
    iszero(a) && return(one(DoubleF64))

    x2 = square(a)
    r = one(a)
    a = one(a)
    for i = 2:4:(nused_inv_fact-2)
        r = r * x2
        t = r * inv_fact[i]
        a = a - t
        r = r * x2
        t = r * inv_fact[i+2]
        a = a + t
    end

    return a
end

function sincos_taylor(a::DoubleF64)
    if iszero(a)
        return a, (one(DoubleF64))
    end
    s = sin_taylor(a)
    c = cos_taylor(a)
    return s,c
end


function tan_taylor(a::DoubleF64)
    iszero(a) && return(zero(DoubleF64))
    a2 = square(a)
    b = a
    r = a
    for i in 2:n_tan_coeff
        b = b * a2
        c = tan_coeff[i] * b
        r += c
    end
    return r
end

function csc_taylor(a::DoubleF64)
    return inv(sin_taylor(a))
end

function sec_taylor(a::DoubleF64)
    return inv(cos_taylor(a))
end

function cot_taylor(a::DoubleF64)
    iszero(a) && return(zero(DoubleF64))
    a2 = square(a)
    b = inv(a)
    r = b
    for i in 2:n_cot_coeff
        b = b * a2
        c = cot_coeff[i] * b
        r += c
    end
    return r
 end




function index_npio32(x::DoubleFloat{T}) where {T<:AbstractFloat}
    result = 1
    while x >= npio32[result]
        result += 1
    end
    return result-1
end


#=
   sin(a+b) = sin(a)*cos(b) + cos(a)*sin(b)
   cos(a+b) = cos(a)*cos(b) - sin(a)*sin(b)
=#



@inline function sin_circle(x::DoubleFloat{T}) where {T<:AbstractFloat}
    idx = index_npio32(x)
    pipart = npio32[idx]
    rest = x - pipart
    sin_part = sin_npio32[idx]
    cos_part = cos_npio32[idx]
    sin_rest, cos_rest = sincos_taylor(rest)
    result1 = sin_part * cos_rest
    result2 = cos_part * sin_rest
    result  = result1 + result2
    return result
end

@inline function cos_circle(x::DoubleFloat{T}) where {T<:AbstractFloat}
    idx = index_npio32(x)
    pipart = npio32[idx]
    rest = x - pipart
    sin_part = sin_npio32[idx]
    cos_part = cos_npio32[idx]
    sin_rest, cos_rest = sincos_taylor(rest)
    result1 = cos_part * cos_rest
    result2 = sin_part * sin_rest
    result  = result1 - result2
    return result
end


@inline function tan_circle(x::DoubleFloat{T}) where {T<:AbstractFloat}
    idx = index_npio32(x)
    pipart = npio32[idx]
    rest = x - pipart
    sin_part = sin_npio32[idx]
    cos_part = cos_npio32[idx]
    sin_rest, cos_rest = sincos_taylor(rest)
    sin_result1 = sin_part * cos_rest
    sin_result2 = cos_part * sin_rest
    sin_result  = sin_result1 + sin_result2
    cos_result1 = cos_part * cos_rest
    cos_result2 = sin_part * sin_rest
    cos_result  = cos_result1 - cos_result2
    return sin_result / cos_result
end



function sincos_circle(x::DoubleFloat{T}) where {T<:AbstractFloat}
    idx = index_npio32(x)
    pipart = npio32[idx]
    rest = x - pipart
    sin_part = sin_npio32[idx]
    cos_part = cos_npio32[idx]
    sin_rest, cos_rest = sincos_taylor(rest)
    s1 = sin_part * cos_rest
    s2 = cos_part * sin_rest
    s  = s1 + s2
    c1 = cos_part * cos_rest
    c2 = sin_part * sin_rest
    c  = c1 - c2
    return s, c
end


function sin(x::DoubleFloat{T}) where {T<:AbstractFloat}
    signbit(x) && return -sin(abs(x))
    iszero(x) && return zero(typeof(x))
    !isfinite(x) && return nan(typeof(x))
    if x >= twopi
       x = mod2pi(x)
    end
    if x >= onepi
       z = -sin_circle(x - onepi)
    elseif x >= halfpi
       z = cos_circle(x - halfpi)
    else
       z = sin_circle(x)
    end
    return z
end


function cos(x::DoubleFloat{T}) where {T<:AbstractFloat}
    signbit(x) && return cos(abs(x))
    iszero(x) && return one(typeof(x))
    !isfinite(x) && return nan(typeof(x))
    if x >= twopi
       x = mod2pi(x)
    end
    if x >= onepi
       z = -cos_circle(x - onepi)
    elseif x >= halfpi
       z = -sin_circle(x - halfpi)
    else
       z = cos_circle(x)
    end
    return z
end


function tan(x::DoubleF64)
    iszero(x) && return zero(typeof(x))
    !isfinite(x) && return nan(typeof(x))
    signbit(x) && return -tan(-x)
    
    y = modpi(x)
    if y >= halfpi
        y = value_minus_pi(y)
        return tan(y)
    elseif y >= qrtrpi
        y = value_minus_qrtrpi(y)
        t = tan(y)
        return (1+t)/(1-t)
    end
    return tan_circle(y)
end




const tan0qrtrpi_numercoeffs = [
 DoubleF64(-4.589387262410812e-34, 3.615269061456329e-50),
 DoubleF64(-1.1277602868617984, -3.7260835757356473e-17),
 DoubleF64(0.023504022820282806, -8.687970367035411e-19),
 DoubleF64(0.15800109650013386, 1.0039888332689995e-17),
 DoubleF64(-0.0032234179678582767, 7.13543487768582e-20),
 DoubleF64(-0.00485067399529607, 2.5007870884389995e-19),
 DoubleF64(9.183636558700604e-5, 6.505326980348073e-21),
 DoubleF64(4.3378563109937034e-5, -1.5862612770718012e-21),
 DoubleF64(-6.679371552585612e-7, 2.526644583588966e-24),
 DoubleF64(-8.978969477885054e-8, 4.807483176770941e-24),
 DoubleF64(6.62853386447739e-10, 1.0925131977072127e-26)
];

const tan0qrtrpi_denomcoeffs = [
 DoubleF64(-1.1277602868617984, -3.726083575735698e-17),
 DoubleF64(0.023504022820282806, -8.68797036610413e-19),
 DoubleF64(0.5339211921207333, 5.0215742527305713e-17),
 DoubleF64(-0.011058092241285879, 2.163933343013038e-19),
 DoubleF64(-0.03245636645396739, -2.0950660440965625e-18),
 DoubleF64(0.0006439974033112582, -4.907277021564753e-20),
 DoubleF64(0.0005359286750031091, 3.4429445937395886e-20),
 DoubleF64(-9.392512261553479e-6, -6.384836458590209e-22),
 DoubleF64(-2.4709845162823393e-6, -1.6760465043339782e-22),
 DoubleF64(3.015269279339435e-8, -8.41236508210075e-25),
 DoubleF64(1.5859442637424446e-9, 6.30689666197131e-26)
];

const tan0qrtrpi_numerpoly = Poly(tan0qrtrpi_numercoeffs);
const tan0qrtrpi_denompoly = Poly(tan0qrtrpi_denomcoeffs);

function tan0qrtrpi(x::DoubleF64)
     numer = polyval(tan0qrtrpi_numerpoly, x)
     denom = polyval(tan0qrtrpi_denompoly, x)
     return numer/denom
end


function csc(x::DoubleFloat{T}) where {T<:AbstractFloat}
    return inv(sin(x))
end

function sec(x::DoubleFloat{T}) where {T<:AbstractFloat}
    return inv(cos(x))
end

function cot(x::DoubleFloat{T}) where {T<:AbstractFloat}
    return inv(tan(x))
end

