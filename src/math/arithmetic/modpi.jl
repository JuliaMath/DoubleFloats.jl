function mod2pi(x::DoubleFloat{T}) where {T<:IEEEFloat}
	s = signbit(x)
	if s
		x = -x
	end
	x < pi2o1(DoubleFloat{T}) && return x
	x < pi4o1(DoubleFloat{T}) && return mod2pi(x - pi2o1(DoubleFloat{T}))
	himdlo = mul323(inv_pi_2o1_t64, HILO(x))
	hi, md, lo = three_sum([modf(x)[1] for x in himdlo]...,)
	if hi >= 1.0
	    hi = hi - 1.0
	    hi, md, lo = three_sum(hi, md, lo)
	end
	himdlo = mul333(pi_2o1_t64, (hi, md, lo))
	if signbit(himdlo[1])
	    himdlo = add333(pi_2o1_t64, himdlo)
	end
	if s
	    himdlo = sub333(pi_2o1_t64, himdlo)
	end
	return DoubleFloat{T}(himdlo[1],himdlo[2])
end

function mod1pi(x::DoubleFloat{T}) where {T<:IEEEFloat}
	s = signbit(x)
	if s
		x = -x
	end
	x < pi1o1(DoubleFloat{T}) && return x
	x < pi2o1(DoubleFloat{T}) && return mod1pi(x - pi1o1(DoubleFloat{T}))
	himdlo = mul323(inv_pi_1o1_t64, HILO(x))
	hi, md, lo = three_sum([modf(x)[1] for x in himdlo]...,)
	if hi >= 1.0
	    hi = hi - 1.0
	    hi, md, lo = three_sum(hi, md, lo)
	end
	himdlo = mul333(pi_1o1_t64, (hi, md, lo))
	if signbit(himdlo[1])
	    himdlo = add333(pi_1o1_t64, himdlo)
    end
	if s
	    himdlo = sub333(pi_1o1_t64, himdlo)
	end
	return DoubleFloat{T}(himdlo[1],himdlo[2])
end

function modhalfpi(x::DoubleFloat{T}) where {T<:IEEEFloat}
	s = signbit(x)
	if s
		x = -x
	end
	x < pi1o2(DoubleFloat{T}) && return x
	x < pi1o1(DoubleFloat{T}) && return modhalfpi(x - pi1o2(DoubleFloat{T}))
	himdlo = mul323(inv_pi_1o2_t64, HILO(x))
	hi, md, lo = three_sum([modf(x)[1] for x in himdlo]...,)
	if hi >= 1.0
	    hi = hi - 1.0
	    hi, md, lo = three_sum(hi, md, lo)
	end
	himdlo = mul333(pi_1o2_t64, (hi, md, lo))
	if signbit(himdlo[1])
	    himdlo = add333(pi_1o2_t64, himdlo)
	end
	if s
	    himdlo = sub333(pi_1o2_t64, himdlo)
	end
	return DoubleFloat{T}(himdlo[1],himdlo[2])
end

function modqrtrpi(x::DoubleFloat{T}) where {T<:IEEEFloat}
	s = signbit(x)
	if s
		x = -x
	end
	x < pi1o4(DoubleFloat{T}) && return x
	x < pi1o2(DoubleFloat{T}) && return modqrtrpi(x - pi1o4(DoubleFloat{T}))
	himdlo = mul323(inv_pi_1o4_t64, HILO(x))
	hi, md, lo = three_sum([modf(x)[1] for x in himdlo]...,)
	if hi >= 1.0
	    hi = hi - 1.0
	    hi, md, lo = three_sum(hi, md, lo)
	end
	himdlo = mul333(pi_1o4_t64, (hi, md, lo))
	if signbit(himdlo[1])
	    himdlo = add333(pi_1o4_t64, himdlo)
	end
	if s
	    himdlo = sub333(pi_1o4_t64, himdlo)
	end
	return DoubleFloat{T}(himdlo[1],himdlo[2])
end

function rem2pi(x::DoubleFloat{T}) where {T<:IEEEFloat}
    m = mod2pi(x)
    return HI(x) < 0 ? -m : m
end

function rem1pi(x::DoubleFloat{T}) where {T<:IEEEFloat}
    m = mod1pi(x)
    return HI(x) < 0 ? -m : m
end

function remhalfpi(x::DoubleFloat{T}) where {T<:IEEEFloat}
    m = modhalfpi(x)
    return HI(x) < 0 ? -m : m
end

function remqrtrpi(x::DoubleFloat{T}) where {T<:IEEEFloat}
    m = modqrtrpi(x)
    return HI(x) < 0 ? -m : m
end



"""
    negpi_pospi(x)

    x --> [-pi..+pi)
"""
function negpi_pospi(x::DoubleFloat{T}) where {T<:IEEEFloat}
    result = mod2pi(x)
    if result >= DoubleFloat{T}(pi)
        result = result - 2*DoubleFloat{T}(pi)
    end
    return result
end



# in -pi..+pi
# determine nearest multiple of pi/2
# within (pi/2) quadrant determine nearest multiple of pi/16

function whichquadrant(x::DoubleFloat{T}) where {T<:IEEEFloat}
    x = negpi_pospi(x)	
    if signbit(x) # quadrant -2 or -1
        quadrant = -x < DoubleFloat{T}(pi)/2 ? -2 : -1
    else          # quadrant  1 or  2
        quadrant =  x < DoubleFloat{T}(pi)/2 ? 1 :  2
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

function mod1pipm(x::DoubleFloat{Float64})
    abs(x) < onepi_d64 && return x
    w1 = mul323(inv_pi_1o1_t64, HILO(x))
    w2 = two_sum(w1[1] - trunc(w1[1]), w1[2], w1[3])
    y = mul322(pi_1o1_t64, w2)
    z = Double64(y)
    return z
end

mod1pipm(x::DoubleFloat{Float32}) = DoubleFloat{Float32}(mod1pipm(DoubleFloat{Float64}(x)))
mod1pipm(x::DoubleFloat{Float16}) = DoubleFloat{Float16}(mod1pipm(DoubleFloat{Float64}(x)))

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
rem2pi(x::DoubleFloat{Float64}, rounding::RoundingMode{:Nearest}) = mod1pipm(x)
rem2pi(x::DoubleFloat{Float64}, rounding::RoundingMode{:ToZero}) =
    signbit(x) ? rem2pi(x, RoundUp) : rem2pi(x, RoundDown)

rem2pi(x::DoubleFloat{Float32}, rounding::RoundingMode) =
    DoubleFloat{Float32}(rem2pi(DoubleFloat{Float64}(x), rounding))
rem2pi(x::DoubleFloat{Float16}, rounding::RoundingMode) =
    DoubleFloat{Float16}(rem2pi(DoubleFloat{Float64}(x), rounding))


rem1pi(x::DoubleFloat{Float64}, rounding::RoundingMode{:Down}) = mod1pi(x)
rem1pi(x::DoubleFloat{Float64}, rounding::RoundingMode{:Up}) = -rem1pi(-x, RoundDown)
rem1pi(x::DoubleFloat{Float64}, rounding::RoundingMode{:Nearest}) = modhalfpipm(x)
rem1pi(x::DoubleFloat{Float64}, rounding::RoundingMode{:ToZero}) =
    signbit(x) ? rem1pi(x, RoundUp) : rem1pi(x, RoundDown)

rem1pi(x::DoubleFloat{Float32}, rounding::RoundingMode) =
    DoubleFloat{Float32}(rem1pi(DoubleFloat{Float64}(x), rounding))
rem1pi(x::DoubleFloat{Float16}, rounding::RoundingMode) =
    DoubleFloat{Float16}(rem1pi(DoubleFloat{Float64}(x), rounding))


#=
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

remqrtrpi(x::DoubleFloat{Float32}, rounding::RoundingMode) =
    DoubleFloat{Float32}(remqrtpi(DoubleFloat{Float64}(x), rounding))
remqrtrpi(x::DoubleFloat{Float16}, rounding::RoundingMode) =
DoubleFloat{Float16}(remqrtrpi(DoubleFloat{Float64}(x), rounding))
=#
