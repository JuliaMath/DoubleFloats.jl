
const double_eps  = eps(eps(1.0))
const twopi_accu  = Double(Accuracy, 6.283185307179586, 2.4492935982947064e-16)
const twopi_perf  = Double(Performance, 6.283185307179586, 2.4492935982947064e-16)
const halfpi_accu = Double(Accuracy, 1.5707963267948966, 6.123233995736766e-17)
const halfpi_perf = Double(Performance, 1.5707963267948966, 6.123233995736766e-17)
const pio16_accu  = Double(Accuracy, 0.19634954084936207, 7.654042494670958e-18)
const pio16_perf  = Double(Performance, 0.19634954084936207, 7.654042494670958e-18)

const inv_factorial = [
    Double(1.66666666666666657e-01,  9.25185853854297066e-18),
    Double(4.16666666666666644e-02,  2.31296463463574266e-18),
    Double(8.33333333333333322e-03,  1.15648231731787138e-19),
    Double(1.38888888888888894e-03, -5.30054395437357706e-20),
    Double(1.98412698412698413e-04,  1.72095582934207053e-22),
    Double(2.48015873015873016e-05,  2.15119478667758816e-23),
    Double(2.75573192239858925e-06, -1.85839327404647208e-22),
    Double(2.75573192239858883e-07,  2.37677146222502973e-23),
    Double(2.50521083854417202e-08, -1.44881407093591197e-24),
    Double(2.08767569878681002e-09, -1.20734505911325997e-25),
    Double(1.60590438368216133e-10,  1.25852945887520981e-26),
    Double(1.14707455977297245e-11,  2.06555127528307454e-28),
    Double(7.64716373181981641e-13,  7.03872877733453001e-30),
    Double(4.77947733238738525e-14,  4.39920548583408126e-31),
    Double(2.81145725434552060e-15,  1.65088427308614326e-31),
    Double(1.56192069685862250e-16,  1.19106796602737540e-32),
    Double(8.22063524662433000e-18,  2.21418941196042650e-34),
    Double(4.11031762331216500e-19,  1.44129733786595270e-36),
    #Double(1.95729410633912630e-20, -1.36435038300879080e-36),
    #Double(8.89679139245057400e-22, -7.91140261487237600e-38),
    #Double(3.86817017063068400e-23, -8.84317765548234400e-40),
    #Double(1.61173757109611840e-24, -3.68465735645097660e-41)
]

const ninv_factorial = length(inv_factorial)
const ninv_factorial_performance = ninv_factorial - 4

#=
     sin(a) from the Taylor series.
     Assumes |a| <= pi/32.
=#
function sin_taylor(a::Double{Float64, Accuracy})
    iszero(a) && return(a)

    x = -square(a)
    r = a
    for i = 3:2:ninv_fact_accu
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
    for i = 2:4:(ninv_fact_accu-2)
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
    for i = 3:2:ninv_fact_perf
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
    for i = 2:4:(ninv_fact_perf-2)
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
