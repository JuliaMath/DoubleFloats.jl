
const double_eps  = eps(eps(1.0))
const twopi_accu  = Double(Accuracy, 6.283185307179586, 2.4492935982947064e-16)
const twopi_perf  = Double(Performance, 6.283185307179586, 2.4492935982947064e-16)
const halfpi_accu = Double(Accuracy, 1.5707963267948966, 6.123233995736766e-17)
const halfpi_perf = Double(Performance, 1.5707963267948966, 6.123233995736766e-17)
const pio16_accu  = Double(Accuracy, 0.19634954084936207, 7.654042494670958e-18)
const pio16_perf  = Double(Performance, 0.19634954084936207, 7.654042494670958e-18)

#=
     sin(a) from the Taylor series.
     Assumes |a| <= pi/32.
=#
function sin_taylor(a::Double{Float64, Accuracy})
    iszero(a) && return(a)

    x = -square(a)
    r = a
    for i = 3:2:nused_inv_fact_accu
        r = r * x
        t = r * inv_fact_accu[i]
        a = a + t
    end

    return a
end


#=
   1 - x^2/2! + x^4/4! - x^6/6! + x^8/8! ...
=#
function cos_taylor(a::Double{Float64, Accuracy})
    iszero(a) && return(one(Double{Float64, Accuracy}))

    x2 = square(a)
    r = one(a)
    a = one(a)
    for i = 2:4:(nused_inv_fact_accu-2)
        r = r * x2
        t = r * inv_fact_accu[i]
        a = a - t
        r = r * x2
        t = r * inv_fact_accu[i+2]
        a = a + t
    end

    return a
end

function sincos_taylor(a::Double{Float64, Accuracy})
    if iszero(a)
        return a, (one(Double{Float64, Accuracy}))
    end
    s = sin_taylor(a)
    c = cos_taylor(a)
    return s,c
end


function tan_taylor(a::Double{Float64, Accuracy})
    s, c = sincos_taylor(a)
    return s/c
end

function csc_taylor(a::Double{Float64, Accuracy})
    return inv(sin_taylor(a))
end

function sec_taylor(a::Double{Float64, Accuracy})
    return inv(cos_taylor(a))
end

function cot_taylor(a::Double{Float64, Accuracy})
    s, c = sincos_taylor(a)
    return c/s
end



function sin_taylor(a::Double{Float64, Performance})
    iszero(a) && return(a)

    x = -square(a)
    r = a
    for i = 3:2:nused_inv_fact_perf
        r = r * x
        t = r * inv_fact_perf[i]
        a = a + t
    end

    return a
end

#=
   1 - x^2/2! + x^4/4! - x^6/6! + x^8/8! ...
=#
function cos_taylor(a::Double{Float64, Performance})
    iszero(a) && return(one(Double{Float64, Performance}))

    x2 = square(a)
    r = one(a)
    a = one(a)
    for i = 2:4:(nused_inv_fact_perf-2)
        r = r * x2
        t = r * inv_fact_perf[i]
        a = a - t
        r = r * x2
        t = r * inv_fact_perf[i+2]
        a = a + t
    end

    return a
end

function sincos_taylor(a::Double{Float64, Performance})
    if iszero(a)
        return a, (one(Double{Float64, Performance}))
    end

    s = sin_taylor(a)
    c = cos_taylor(a)
    return s,c
end


function tan_taylor(a::Double{Float64, Performance})
    s, c = sincos_taylor(a)
    return s/c
end

function csc_taylor(a::Double{Float64, Performance})
    return inv(sin_taylor(a))
end

function sec_taylor(a::Double{Float64, Performance})
    return inv(cos_taylor(a))
end

function cot_taylor(a::Double{Float64, Performance})
    s, c = sincos_taylor(a)
    return c/s
end


function index_npio32(x::Double{T,Accuracy}) where {T<:AbstractFloat}
    result = 1
    while x >= npio32_accu[result]
        result += 1
    end
    return result-1
end

function index_npio32(x::Double{T,Performance}) where {T<:AbstractFloat}
    result = 1
    while x >= npio32_perf[result]
        result += 1
    end
    return result-1
end


#=
   sin(a+b) = sin(a)*cos(b) + cos(a)*sin(b)
   cos(a+b) = cos(a)*cos(b) - sin(a)*sin(b)
=#



@inline function sin_circle(x::Double{T,Accuracy}) where {T<:AbstractFloat}
    idx = index_npio32(x)
    pipart = npio32_accu[idx]
    rest = x - pipart
    sin_part = sin_npio32_accu[idx]
    cos_part = cos_npio32_accu[idx]
    sin_rest, cos_rest = sincos_taylor(rest)
    result1 = sin_part * cos_rest
    result2 = cos_part * sin_rest
    result  = result1 + result2
    return result
end

@inline function cos_circle(x::Double{T,Accuracy}) where {T<:AbstractFloat}
    idx = index_npio32(x)
    pipart = npio32_accu[idx]
    rest = x - pipart
    sin_part = sin_npio32_accu[idx]
    cos_part = cos_npio32_accu[idx]
    sin_rest, cos_rest = sincos_taylor(rest)
    result1 = cos_part * cos_rest
    result2 = sin_part * sin_rest
    result  = result1 - result2
    return result
end

function sincos_circle(x::Double{T,Accuracy}) where {T<:AbstractFloat}
    idx = index_npio32(x)
    pipart = npio32_accu[idx]
    rest = x - pipart
    sin_part = sin_npio32_accu[idx]
    cos_part = cos_npio32_accu[idx]
    sin_rest, cos_rest = sincos_taylor(rest)
    s1 = sin_part * cos_rest
    s2 = cos_part * sin_rest
    s  = s1 + s2
    c1 = cos_part * cos_rest
    c2 = sin_part * sin_rest
    c  = c1 - c2
    return s, c
end



@inline function sin_circle(x::Double{T,Performance}) where {T<:AbstractFloat}
    idx = index_npio32(x)
    pipart = npio32_perf[idx]
    rest = x - pipart
    sin_part = sin_npio32_perf[idx]
    cos_part = cos_npio32_perf[idx]
    sin_rest, cos_rest = sincos_taylor(rest)
    result1 = sin_part * cos_rest
    result2 = cos_part * sin_rest
    result  = result1 + result2
    return result
end

@inline function cos_circle(x::Double{T,Performance}) where {T<:AbstractFloat}
    idx = index_npio32(x)
    pipart = npio32_perf[idx]
    rest = x - pipart
    sin_part = sin_npio32_perf[idx]
    cos_part = cos_npio32_perf[idx]
    sin_rest, cos_rest = sincos_taylor(rest)
    result1 = cos_part * cos_rest
    result2 = sin_part * sin_rest
    result  = result1 - result2
    return result
end


function sincos_circle(x::Double{T,Performance}) where {T<:AbstractFloat}
    idx = index_npio32(x)
    pipart = npio32_perf[idx]
    rest = x - pipart
    sin_part = sin_npio32_perf[idx]
    cos_part = cos_npio32_perf[idx]
    sin_rest, cos_rest = sincos_taylor(rest)
    s1 = sin_part * cos_rest
    s2 = cos_part * sin_rest
    s  = s1 + s2
    c1 = cos_part * cos_rest
    c2 = sin_part * sin_rest
    c  = c1 - c2
    return s, c
end


function sin(x::Double{T,Accuracy}) where {T<:AbstractFloat}
    iszero(x) && return zero(typeof(x))
    !isfinite(x) && return nan(typeof(x))
    y = abs(x)
    if y >= twopi_accu
       y = y / twopi_accu
       y = modf(y)[1]
    end
    z = sin_circle(y)
    z = copysign(z, x)
    return z
end

function sin(x::Double{T,Performance}) where {T<:AbstractFloat}
    iszero(x) && return zero(typeof(x))
    !isfinite(x) && return nan(typeof(x))
    y = abs(x)
    if y >= twopi_perf
       y = y / twopi_perf
       y = modf(y)[1]
    end
    z = sin_circle(y)
    z = copysign(z, x)
    return z
end


function cos(x::Double{T,Accuracy}) where {T<:AbstractFloat}
    iszero(x) && return one(typeof(x))
    !isfinite(x) && return nan(typeof(x))
    y = abs(x)
    if y >= twopi_accu
       y = y / twopi_accu
       y = modf(y)[1]
    end
    z = cos_circle(y)
    return z
end

function cos(x::Double{T,Performance}) where {T<:AbstractFloat}
    iszero(x) && return one(typeof(x))
    !isfinite(x) && return nan(typeof(x))
    y = abs(x)
    if y >= twopi_perf
       y = y / twopi_perf
       y = modf(y)[1]
    end
    z = cos_circle(y)
    return z
end

function sincos(x::Double{T,Accuracy}) where {T<:AbstractFloat}
    iszero(x) && return zero(typeof(x)), one(typeof(x))
    !isfinite(x) && return nan(typeof(x)), nan(typeof(x))
    y = abs(x)
    if y >= twopi_accu
       y = y / twopi_accu
       y = modf(y)[1]
    end
    s = sin_circle(y)
    s = copysign(s, x)
    c = cos_circle(y)
    return s, c
end

function sincos(x::Double{T,Performance}) where {T<:AbstractFloat}
    iszero(x) && return zero(typeof(x)), one(typeof(x))
    !isfinite(x) && return nan(typeof(x)), nan(typeof(x))
    y = abs(x)
    if y >= twopi_perf
       y = y / twopi_perf
       y = modf(y)[1]
    end
    s = sin_circle(y)
    s = copysign(s, x)
    c = cos_circle(y)
    return s, c
end

#=
function sin(x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
    iszero(x) && return zero(typeof(x))
    !isfinite(x) && return nan(typeof(x))
    y = abs(x)
    two_pi = Double(E, HI(twopi_accuracy), LO(twopi_accuracy))
    if y >= two_pi
       y = y / two_pi
       y = modf(y)[1]
    end
    z = sin_circle(y)
    z = copysign(z, x)
    return z
end
function cos(x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
    iszero(x) && return one(typeof(x))
    !isfinite(x) && return nan(typeof(x))
    y = abs(x)
    two_pi = Double(E, HI(twopi_accuracy), LO(twopi_accuracy))
    if y >= two_pi
       y = y / two_pi
       y = modf(y)[1]
    end
    z = cos_circle(y)
    return z
end
function sincos(x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
    iszero(x) && return zero(typeof(x)), one(typeof(x))
    !isfinite(x) && return nan(typeof(x)), nan(typeof(x))
    y = abs(x)
    two_pi = Double(E, HI(twopi_accuracy), LO(twopi_accuracy))
    if y >= two_pi
       y = y / two_pi
       y = modf(y)[1]
    end
    s = sin_circle(y)
    s = copysign(s, x)
    c = cos_circle(y)
    return s, c
end
=#

function tan(x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
    s, c = sincos(x)
    return s/c
end

function csc(x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
    return inv(sin(x))
end

function sec(x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
    return inv(cos(x))
end

function cot(x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
    s, c = sin(x), cos(x)
    return c/s
end
