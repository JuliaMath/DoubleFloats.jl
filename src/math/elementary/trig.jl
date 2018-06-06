const twopi  = DoubleF64(6.283185307179586, 2.4492935982947064e-16)
const onepi  = DoubleF64(3.141592653589793, 1.2246467991473532e-16)
const halfpi = DoubleF64(1.5707963267948966, 6.123233995736766e-17)


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
    z = sin_circle(x)
    return z
end


function cos(x::DoubleFloat{T}) where {T<:AbstractFloat}
    signbit(x) && return cos(abs(x))
    iszero(x) && return one(typeof(x))
    !isfinite(x) && return nan(typeof(x))
    if x >= twopi
       x = mod2pi(x)
    end
    z = cos_circle(x)
    return z
end


function tan(x::DoubleFloat{T}) where {T<:AbstractFloat}
    signbit(x) && return -tan(abs(x))
    iszero(x) && return zero(typeof(x))
    !isfinite(x) && return nan(typeof(x))
    if x >= halfpi
       x = modhalfpi(x)
    end
    z = tan_circle(x)
    return z
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

#=
function sincos(x::DoubleFloat{T}) where {T<:AbstractFloat}
    iszero(x) && return zero(typeof(x)), one(typeof(x))
    !isfinite(x) && return nan(typeof(x)), nan(typeof(x))
    if !signbit(x)
       sincos_posx(x)
    else
       sincos_negx(x)
    end
end


@inline function sincos_posx(x::DoubleFloat{T}) where {T<:AbstractFloat}
    if x >= twopi
       x = mod2pi(x)
    end
    s = sin_circle(x)
    c = cos_circle(x)
    return s, c
end


@inline function sincos_negx(x::DoubleFloat{T}) where {T<:AbstractFloat}
    x = abs(x)
    if x >= twopi
       x = mod2pi(x)
    end
    s = -sin_circle(x)
    c = cos_circle(x)
    return s, c
end

=#
