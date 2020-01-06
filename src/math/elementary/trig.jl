const twopi  = Double64(6.283185307179586, 2.4492935982947064e-16)
const onepi  = Double64(3.141592653589793, 1.2246467991473532e-16)
const halfpi = Double64(1.5707963267948966, 6.123233995736766e-17)
const qrtrpi = Double64(0.7853981633974483, 3.061616997868383e-17)
const sixteenthpi = Double64(0.19634954084936207, 7.654042494670958e-18)
const thirtysecondpi = Double64(0.09817477042468103, 3.827021247335479e-18)
const threesixteenthpi = Double64(0.5890486225480862, 2.296212748401287e-17)

atanxy(x::T, y::T) where {T<:Real} = atan(y, x)

#=
     sin(a) from the Taylor series.
     Assumes |a| <= pi/32.
=#
function sin_taylor(a::Double64)
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
function cos_taylor(a::Double64)
    iszero(a) && return(one(Double64))

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

function sincos_taylor(a::Double64)
    if iszero(a)
        return a, (one(Double64))
    end
    s = sin_taylor(a)
    c = cos_taylor(a)
    return s,c
end


function tan_taylor(a::Double64)
    iszero(a) && return(zero(Double64))
    s = sin_taylor(a)
    c = cos_taylor(a)
    return s/c
end

function csc_taylor(a::Double64)
    return inv(sin_taylor(a))
end

function sec_taylor(a::Double64)
    return inv(cos_taylor(a))
end

function cot_taylor(a::Double64)
    iszero(a) && return(zero(Double64))
    s = sin_taylor(a)
    c = cos_taylor(a)
    return c/s
 end




function index_npio32(x::DoubleFloat{T}) where {T<:IEEEFloat}
    x < npio32[1] && return 1
    x >= npio32[end] && return length(npio32)
    result = 1
    while x >= npio32[result]
        result += 1
    end
    return max(1,result-1)
end


#=
   sin(a+b) = sin(a)*cos(b) + cos(a)*sin(b)
   cos(a+b) = cos(a)*cos(b) - sin(a)*sin(b)
=#



@inline function sin_circle(x::DoubleFloat{T}) where {T<:IEEEFloat}
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

@inline function cos_circle(x::DoubleFloat{T}) where {T<:IEEEFloat}
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


@inline function tan_circle(x::DoubleFloat{T}) where {T<:IEEEFloat}
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



function sincos_circle(x::DoubleFloat{T}) where {T<:IEEEFloat}
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


@inline function sin_kernel(x::DoubleFloat{T}) where {T<:IEEEFloat}
    signbit(x) && return -sin(abs(x))
    iszero(x) && return zero(typeof(x))
    !isfinite(x) && return nan(typeof(x))
    if x >= twopi
       x = mod2pi(x)
    end
    if x >= onepi
       z = -sin_circle(x_minus_onepi(x))
    elseif x >= halfpi
       z = cos_circle(x_minus_halfpi(x))
    elseif x <= thirtysecondpi
       z = sin_taylor(x)
    else
       z = sin_circle(x)
    end
    return z
end

@inline function cos_kernel(x::DoubleFloat{T}) where {T<:IEEEFloat}
    signbit(x) && return cos(abs(x))
    iszero(x) && return one(typeof(x))
    !isfinite(x) && return nan(typeof(x))
    if x >= twopi
       x = mod2pi(x)
    end
    if x >= onepi
       z = -cos_circle(x_minus_onepi(x))
    elseif x >= halfpi
       z = -sin_circle(x_minus_halfpi(x))
    elseif x <= thirtysecondpi
       z = cos_taylor(x)
    else
       z = cos_circle(x)
    end
    return z
end

function cos(x::DoubleFloat{T}) where {T<:IEEEFloat}
    isnan(x) && return x
    isinf(x) && throw(DomainError("cos(x) only defined for finite x"))
    return abs(x.hi) < 6.28125 ? cos_kernel(x) : DoubleFloat{T}(cos(Quadmath.Float128(x)))
end

function sin(x::DoubleFloat{T}) where {T<:IEEEFloat}
    isnan(x) && return x
    isinf(x) && throw(DomainError("sin(x) only defined for finite x"))
    return abs(x.hi) < 6.28125 ? sin_kernel(x) : DoubleFloat{T}(sin(Quadmath.Float128(x)))
end

Base.sincos(x::DoubleFloat) = (sin(x), cos(x))

#=
function tangent(x::T) where {T}
    signbit(x) && return -tangent(abs(x))
    x > halfpi(T) && return tangent(DoubleFloats.modhalfpi(x))
    x > qrtrpi(T) && return inv(tangent_0_qrtrpi(halfpi(T)-x))
    return sin(x)/cos(x)
end
function tangent_0_qrtrpi(x)
   c = cos(x)                #  c = cos(x); cc = c*c; return sqrt((1-cc)/cc)
   s = sqrt(1 - c*c)
   return s/c
end

=#
function tan(x::Double64)
    isnan(x) && return x
    isinf(x) && throw(DomainError("tan(x) only defined for finite x"))
    abs(HI(x)) >= 0.36815538909255385 && return Double64(tan(Float128(x)))  # (15/128 * pi)
     
    abs(mod1pi(x-Double64(pi)/2)) <= eps(one(DoubleFloat{Float64})) && return DoubleFloat{Float64}(Inf)
    iszero(x) && return zero(typeof(x))
    !isfinite(x) && return nan(typeof(x))
    signbit(x) && return -tan(-x)
    HI(x) <= 2.0e-12 && return x

    y = mod1pi(x)                        # 0 <= y < pi
    if y >= halfpi
        y = x_minus_onepi(y)                # -pi/2 < y < 0
        return tan(y)
    elseif y >= qrtrpi
        y = x_minus_qrtrpi(y)       # 0 < y < pi/4
        t = tan(y)
        return (1+t)/(1-t)
    elseif y >= threesixteenthpi
        y = -x_minus_qrtrpi(y)     #   0 < y < pi/16
        t = tan(y)
        return (1-t)/(1+t)
    end
    return tan_circle(y)               # 0 <= y < 3pi/16 [(3/4 * pi/4)< 0.5891]
end




const tan0qrtrpi_numercoeffs = [
 Double64(-4.589387262410812e-34, 3.615269061456329e-50),
 Double64(-1.1277602868617984, -3.7260835757356473e-17),
 Double64(0.023504022820282806, -8.687970367035411e-19),
 Double64(0.15800109650013386, 1.0039888332689995e-17),
 Double64(-0.0032234179678582767, 7.13543487768582e-20),
 Double64(-0.00485067399529607, 2.5007870884389995e-19),
 Double64(9.183636558700604e-5, 6.505326980348073e-21),
 Double64(4.3378563109937034e-5, -1.5862612770718012e-21),
 Double64(-6.679371552585612e-7, 2.526644583588966e-24),
 Double64(-8.978969477885054e-8, 4.807483176770941e-24),
 Double64(6.62853386447739e-10, 1.0925131977072127e-26)
];

const tan0qrtrpi_denomcoeffs = [
 Double64(-1.1277602868617984, -3.726083575735698e-17),
 Double64(0.023504022820282806, -8.68797036610413e-19),
 Double64(0.5339211921207333, 5.0215742527305713e-17),
 Double64(-0.011058092241285879, 2.163933343013038e-19),
 Double64(-0.03245636645396739, -2.0950660440965625e-18),
 Double64(0.0006439974033112582, -4.907277021564753e-20),
 Double64(0.0005359286750031091, 3.4429445937395886e-20),
 Double64(-9.392512261553479e-6, -6.384836458590209e-22),
 Double64(-2.4709845162823393e-6, -1.6760465043339782e-22),
 Double64(3.015269279339435e-8, -8.41236508210075e-25),
 Double64(1.5859442637424446e-9, 6.30689666197131e-26)
];

const tan0qrtrpi_numerpoly = Poly(tan0qrtrpi_numercoeffs);
const tan0qrtrpi_denompoly = Poly(tan0qrtrpi_denomcoeffs);

function tan0qrtrpi(x::Double64)
     numer = polyval(tan0qrtrpi_numerpoly, x)
     denom = polyval(tan0qrtrpi_denompoly, x)
     return numer/denom
end


function csc(x::DoubleFloat{T}) where {T<:IEEEFloat}
    isnan(x) && return x 
    isinf(x) && throw(DomainError("csc(x) only defined for finite x"))
    return inv(sin(x))
end

function sec(x::DoubleFloat{T}) where {T<:IEEEFloat}
    isnan(x) && return x
    isinf(x) && throw(DomainError("sec(x) only defined for finite x"))
    return inv(cos(x))
end

function cot(x::DoubleFloat{T}) where {T<:IEEEFloat}
    isnan(x) && return x
    isinf(x) && throw(DomainError("cot(x) only defined for finite x"))
    abs(mod1pi(x)) <= eps(one(DoubleFloat{T})) && return DoubleFloat{T}(Inf)
    return inv(tan(x))
end

function sinpi(x::DoubleFloat{T}) where {T<:IEEEFloat}
    isnan(x) && return x
    isinf(x) && throw(DomainError("sinpi(x) only defined for finite x"))
    return DoubleFloat{T}(sinpi(Quadmath.Float128(x)))
    #= 
    y = Double64(x) 
    hi,lo = mul322(pi_1o1_t64, HILO(y))
    y = Double64(hi, lo)
    z = sin(y)
    return DoubleFloat{T}(z)
    =#
end

function cospi(x::DoubleFloat{T}) where {T<:IEEEFloat}
    isnan(x) && return x
    isinf(x) && throw(DomainError("cospi(x) only defined for finite x"))
    return DoubleFloat{T}(cospi(Quadmath.Float128(x)))
    #= 
     y = Double64(x) 
    hi,lo = mul322(pi_1o1_t64, HILO(y))
    y = Double64(hi, lo)
    z = cos(y)
    return DoubleFloat{T}(z)
    =#
end

function tanpi(x::DoubleFloat{T}) where {T<:IEEEFloat}
    isnan(x) && return x
    isinf(x) && throw(DomainError("tanpi(x) only defined for finite x"))
    return sinpi(x)/cospi(x)
    #=
    y = Double64(x) 
    hi,lo = mul322(pi_1o1_t64, HILO(y))
    y = Double64(hi, lo)
    z = tan(y)
    return DoubleFloat{T}(z)
    =#
end

