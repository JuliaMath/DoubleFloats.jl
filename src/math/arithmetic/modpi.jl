function mod2pi(x::DoubleFloat{T}) where {T<:IEEEFloat}
    s = signbit(x)
	if s
		x = -x
	end
	himdlo = mul323(inv_pi_2o1_t64, HILO(x))
	hi, md, lo = three_sum([modf(x)[1] for x in himdlo]...,)
	himdlo = three_sumof4(-1.0, hi, md, lo)
	himdlo = mul333(himdlo, pi_2o1_t64)
	if himdlo[1] < 0.0
	   himdlo = add333(himdlo, pi_2o1_t64)
	end
	if s
	   himdlo = sub333(pi_2o1_t64, himdlo)
	end
	return Double64(himdlo[1], himdlo[2])
end

function modpi(x::DoubleFloat{T}) where {T<:IEEEFloat}
    s = signbit(x)
	if s
		x = -x
	end
	himdlo = mul323(inv_pi_1o1_t64, HILO(x))
	hi, md, lo = three_sum([modf(x)[1] for x in himdlo]...,)
	himdlo = three_sumof4(-1.0, hi, md, lo)
	himdlo = mul333(himdlo, pi_1o1_t64)
	if himdlo[1] < 0.0
	   himdlo = add333(himdlo, pi_1o1_t64)
	end
	if s
	   himdlo = sub333(pi_1o1_t64, himdlo)
	end
	return Double64(himdlo[1], himdlo[2])
end


#=
    x / 2pi
            x * tripleprecision(inv(2pi))
            intpart, fracpart
=#
function rem2pi(x::T) where {F<:IEEEFloat, T<:DoubleFloat{F}}
    hi, md, lo = mul233(HILO(x), inv_pi_2o1_t64)

    intfrac_hi = modf(hi)
    intfrac_md = modf(md)
    intfrac_lo = modf(lo)
    fracparts = intfrac_hi[1], intfrac_md[1], intfrac_lo[1]
    # fracpart is the signed (directed) portion of a circle
    hi, md, lo = mul333(fracparts, pi_2o1_t64)
    return T(hi, md)
end

function rem1pi(x::T) where {F<:IEEEFloat, T<:DoubleFloat{F}}
    hi, md, lo = mul233(HILO(x), inv_pi_1o1_t64)

    intfrac_hi = modf(hi)
    intfrac_md = modf(md)
    intfrac_lo = modf(lo)
    fracparts = intfrac_hi[1], intfrac_md[1], intfrac_lo[1]
    # fracpart is the signed (directed) portion of a circle
    hi, md, lo = mul333(fracparts, pi_1o1_t64)
    return T(hi, md)
end

"""
    negpi_pospi(x)

    x --> [-pi..+pi)
"""
function negpi_pospi(x::T) where {F<:IEEEFloat, T<:DoubleFloat{F}}
    result = rem2pi(x)
    if result >= T(pi)
        result = -rem2pi(-x)
    end
    return result
end



# in -pi..+pi
# determine nearest multiple of pi/2
# within (pi/2) quadrant determine nearest multiple of pi/16

function whichquadrant(x::T) where {F<:IEEEFloat, T<:DoubleFloat{F}}
    if signbit(x) # quadrant -2 or -1
        quadrant = -x < T(pi)/2 ? -2 : -1
    else          # quadrant  1 or  2
        quadrant =  x < T(pi)/2 ? 1 :  2
    end
    return quadrant
end

function which64th(x::DoubleFloat{Float64}, quadrant::Int)
    y = T(mul232(HILO(x), nv_pi_1o2_t64))
    z = trunc(Int, y*4)
    return z
end
function which64th(x::DoubleFloat{Float32}, quadrant::Int)
    y = T(mul232(HILO(x), nv_pi_1o2_t32))
    z = trunc(Int, y*4)
    return z
end
function which64th(x::DoubleFloat{Float16}, quadrant::Int)
    y = T(mul232(HILO(x), nv_pi_1o2_t16))
    z = trunc(Int, y*4)
    return z
end


# ========================================== ^^^^^ =========================================

const pi_1o1_t64_hi = pi_1o1_t64[1]
const pi_1o1_t64_md = pi_1o1_t64[2]
const pi_1o1_t64_lo = pi_1o1_t64[3]

const pi_1o4_t64_hi = pi_1o4_t64[1]
const pi_1o4_t64_md = pi_1o4_t64[2]
const pi_1o4_t64_lo = pi_1o4_t64[3]

function value_minus_pi(x::DoubleFloat{Float64})
    hi, lo = sub232(HI(x), LO(x), pi_1o1_t64_hi, pi_1o1_t64_md, pi_1o1_t64_lo)
    return DoubleFloat{Float64}(hi, lo)
end

function value_minus_qrtrpi(x::DoubleFloat{Float64})
    hi, lo = sub232(HI(x), LO(x), pi_1o4_t64_hi, pi_1o4_t64_md, pi_1o4_t64_lo)
    return DoubleFloat{Float64}(hi, lo)
end


function mod2pi(x1::DoubleFloat{Float64}, x2::DoubleFloat{Float64})
    w1 = mul323(inv_pi_2o1_t64, HILO(x1))
    w2 = two_sumof3(w1[1] - trunc(w1[1]), w1[2], w1[3])
    y = mul322(pi_2o1_t64, w2)
    z1 = Double64(y)
    w1 = mul323(inv_pi_2o1_t64, HILO(x2))
    w2 = two_sumof3(w1[1] - trunc(w1[1]), w1[2], w1[3])
    y = mul322(pi_2o1_t64, w2)
    z2 = Double64(y)
    x3 = z1 + z2
    w1 = mul323(inv_pi_2o1_t64, HILO(x3))
    w2 = two_sumof3(w1[1] - trunc(w1[1]), w1[2], w1[3])
    y = mul322(pi_2o1_t64, w2)
    return Double64(y)
end

function mod2pi_neg(x::DoubleFloat{Float64})
    m = mod2pi(-x)
    return Double64(sub322(pi_2o1_t64, HILO(m)))
end

mod2pi(x::DoubleFloat{Float32}) = DoubleFloat{Float32}(mod2pi(DoubleFloat{Float64}(x)))
mod2pi(x::DoubleFloat{Float16}) = DoubleFloat{Float16}(mod2pi(DoubleFloat{Float64}(x)))


function modpi_neg(x::DoubleFloat{Float64})
    m = modpi(-x)
    return Double64(sub322(pi_1o1_t64, HILO(m)))
end
modpi(x::DoubleFloat{Float32}) = DoubleFloat{Float32}(modpi(DoubleFloat{Float64}(x)))
modpi(x::DoubleFloat{Float16}) = DoubleFloat{Float16}(modpi(DoubleFloat{Float64}(x)))

function modpipm(x::DoubleFloat{Float64})
    abs(x) < onepi_d64 && return x
    w1 = mul323(inv_pi_1o1_t64, HILO(x))
    w2 = two_sum(w1[1] - trunc(w1[1]), w1[2], w1[3])
    y = mul322(pi_1o1_t64, w2)
    z = Double64(y)
    return z
end

modpipm(x::DoubleFloat{Float32}) = DoubleFloat{Float32}(modpipm(DoubleFloat{Float64}(x)))
modpipm(x::DoubleFloat{Float16}) = DoubleFloat{Float16}(modpipm(DoubleFloat{Float64}(x)))

function modhalfpi(x::DoubleFloat{Float64})
    signbit(x) && return modhalfpi_neg(x)
    x < halfpi_d64 && return x
    w1 = mul323(inv_pi_1o2_t64, HILO(x))
    w2 = two_sum(w1[1] - trunc(w1[1]), w1[2], w1[3])
    y = mul322(pi_1o2_t64, w2)
    z = Double64(y)
    return z
end

function modhalfpi_neg(x::DoubleFloat{Float64})
    m = modhalfpi(-x)
    return Double64(sub322(pi_1o2_t64, HILO(m)))
end

modhalfpi(x::DoubleFloat{Float32}) = DoubleFloat{Float32}(modhalfpi(DoubleFloat{Float64}(x)))
modhalfpi(x::DoubleFloat{Float16}) = DoubleFloat{Float16}(modhalfpi(DoubleFloat{Float64}(x)))

function modhalfpipm(x::DoubleFloat{Float64})
    abs(x) < halfpi_d64 && return x
    w1 = mul323(inv_pi_1o2_t64, HILO(x))
    w2 = two_sum(w1[1] - trunc(w1[1]), w1[2], w1[3])
    y = mul322(pi_1o2_t64, w2)
    z = Double64(y)
    return z
end

modhalfpipm(x::DoubleFloat{Float32}) = DoubleFloat{Float32}(modhalfpipm(DoubleFloat{Float64}(x)))
modhalfpipm(x::DoubleFloat{Float16}) = DoubleFloat{Float16}(modhalfpipm(DoubleFloat{Float64}(x)))

function modqrtrpi(x::DoubleFloat{Float64})
    signbit(x) && return modqrtrpi_neg(x)
    x < qrtrpi_d64 && return x
    w1 = mul323(inv_pi_1o4_t64, HILO(x))
    w2 = two_sum(w1[1] - trunc(w1[1]), w1[2], w1[3])
    y = mul322(pi_1o4_t64, w2)
    z = Double64(y)
    return z
end

function modqrtrpi_neg(x::DoubleFloat{Float64})
    m = modqrtrpi(-x)
    return Double64(sub322(pi_1o4_t64, HILO(m)))
end

modqrtrpi(x::DoubleFloat{Float32}) = DoubleFloat{Float32}(modqrtrpi(DoubleFloat{Float64}(x)))
modqrtrpi(x::DoubleFloat{Float16}) = DoubleFloat{Float16}(modqrtrpi(DoubleFloat{Float64}(x)))

function modqrtrpipm(x::DoubleFloat{Float64})
    abs(x) < qrtrpi_d64 && return x
    w1 = mul323(inv_pi_1o4_t64, HILO(x))
    w2 = two_sum(w1[1] - trunc(w1[1]), w1[2], w1[3])
    y = mul322(pi_1o4_t64, w2)
    z = Double64(y)
    return z
end

modqrtrpipm(x::DoubleFloat{Float32}) = DoubleFloat{Float32}(modqrtrpipm(DoubleFloat{Float64}(x)))
modqrtrpipm(x::DoubleFloat{Float16}) = DoubleFloat{Float16}(modqrtrpipm(DoubleFloat{Float64}(x)))



#=
    rem2pi(x) =  x - 2π*round(x/(2π),r)
    rem2pi(x, RoundDown) == mod2pi(x)
    •    if r == RoundNearest, then the result is in the interval [-π, π]. This will
        generally be the most accurate result.
    •    if r == RoundToZero, then the result is in the interval [0, 2π] if x is positive,.
        or [-2π, 0] otherwise.
    •    if r == RoundDown, then the result is in the interval [0, 2π].
    •    if r == RoundUp, then the result is in the interval [-2π, 0].
=#

rem2pi(x::DoubleFloat{Float64}, rounding::RoundingMode{:Down}) = mod2pi(x)
rem2pi(x::DoubleFloat{Float64}, rounding::RoundingMode{:Up}) = -rem2pi(-x, RoundDown)
rem2pi(x::DoubleFloat{Float64}, rounding::RoundingMode{:Nearest}) = modpipm(x)
rem2pi(x::DoubleFloat{Float64}, rounding::RoundingMode{:ToZero}) =
    signbit(x) ? rem2pi(x, RoundUp) : rem2pi(x, RoundDown)

rem2pi(x::DoubleFloat{Float32}, rounding::RoundingMode) =
    DoubleFloat{Float32}(rem2pi(DoubleFloat{Float64}(x), rounding))
rem2pi(x::DoubleFloat{Float16}, rounding::RoundingMode) =
    DoubleFloat{Float16}(rem2pi(DoubleFloat{Float64}(x), rounding))


rempi(x::DoubleFloat{Float64}, rounding::RoundingMode{:Down}) = modpi(x)
rempi(x::DoubleFloat{Float64}, rounding::RoundingMode{:Up}) = -rempi(-x, RoundDown)
rempi(x::DoubleFloat{Float64}, rounding::RoundingMode{:Nearest}) = modhalfpipm(x)
rempi(x::DoubleFloat{Float64}, rounding::RoundingMode{:ToZero}) =
    signbit(x) ? rempi(x, RoundUp) : rempi(x, RoundDown)

rempi(x::DoubleFloat{Float32}, rounding::RoundingMode) =
    DoubleFloat{Float32}(rempi(DoubleFloat{Float64}(x), rounding))
rempi(x::DoubleFloat{Float16}, rounding::RoundingMode) =
    DoubleFloat{Float16}(rempi(DoubleFloat{Float64}(x), rounding))


remhalfpi(x::DoubleFloat{Float64}, rounding::RoundingMode{:Down}) = modhalfpi(x)
remhalfpi(x::DoubleFloat{Float64}, rounding::RoundingMode{:Up}) = -remhalfpi(-x, RoundDown)
remhalfpi(x::DoubleFloat{Float64}, rounding::RoundingMode{:Nearest}) = modqrtrpipm(x)
remhalfpi(x::DoubleFloat{Float64}, rounding::RoundingMode{:ToZero}) =
    signbit(x) ? remhalfpi(x, RoundUp) : remhalfpi(x, RoundDown)

remhalfpi(x::DoubleFloat{Float32}, rounding::RoundingMode) =
    DoubleFloat{Float32}(remhalfpi(DoubleFloat{Float64}(x), rounding))
remhalfpi(x::DoubleFloat{Float16}, rounding::RoundingMode) =
    DoubleFloat{Float16}(remhalfpi(DoubleFloat{Float64}(x), rounding))

remqrtrpi(x::DoubleFloat{Float64}, rounding::RoundingMode{:Down}) = modqrtrpi(x)
remqrtrpi(x::DoubleFloat{Float64}, rounding::RoundingMode{:Up}) = -remqrtrpi(-x, RoundDown)
# remqrtrpi(x::DoubleFloat{Float64}, rounding::RoundingMode{:Nearest}) = modeighthpipm(x)
remqrtrpi(x::DoubleFloat{Float64}, rounding::RoundingMode{:ToZero}) =
    signbit(x) ? remqrtrpi(x, RoundUp) : remqrtrpi(x, RoundDown)

remqrtepi(x::DoubleFloat{Float32}, rounding::RoundingMode) =
    DoubleFloat{Float32}(remqrtpi(DoubleFloat{Float64}(x), rounding))
remqrtrpi(x::DoubleFloat{Float16}, rounding::RoundingMode) =
DoubleFloat{Float16}(remqrtrpi(DoubleFloat{Float64}(x), rounding))
