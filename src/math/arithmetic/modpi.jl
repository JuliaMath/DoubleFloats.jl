## Edited by Michael Kline, MIT License
## This work was supported in part by the U.S. Department of Energy, Office of Science, Office of Workforce Development for Teachers and Scientists (WDTS) under the Science Undergraduate Laboratory Internships Program (SULI) program at Oak Ridge National Laboratory, administered by the Oak Ridge Institute for Science and Education.

function mod2pi(x::DoubleFloat{T}) where {T<:IEEEFloat}
	s = x < 0
	c = s ? -1 : 1
    y = c * x
	y < pi2o1(DoubleFloat{T}) && return s ? pi2o1(DoubleFloat{T}) - y : y
	y < pi4o1(DoubleFloat{T}) && return mod2pi(x - c*pi2o1(DoubleFloat{T}))
	himdlo = mul323(inv_pi_2o1_t64, HILO(y))
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
	c = s ? -1 : 1
    y = c * x
	x < pi1o1(DoubleFloat{T}) && return s ? pi1o1(DoubleFloat{T}) - y : y
	x < pi2o1(DoubleFloat{T}) && return mod1pi(x - c*pi1o1(DoubleFloat{T}))
	himdlo = mul323(inv_pi_1o1_t64, HILO(y))
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
	c = s ? -1 : 1
    y = c * x
	x < pi1o2(DoubleFloat{T}) && return s ? pi1o2(DoubleFloat{T}) - y : y
	x < pi1o1(DoubleFloat{T}) && return modhalfpi(x - c*pi1o2(DoubleFloat{T}))
	himdlo = mul323(inv_pi_1o2_t64, HILO(y))
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
	c = s ? -1 : 1
    y = c * x
	x < pi1o4(DoubleFloat{T}) && return s ? pi1o4(DoubleFloat{T}) - y : y
	x < pi1o2(DoubleFloat{T}) && return modqrtrpi(x - c*pi1o4(DoubleFloat{T}))
	himdlo = mul323(inv_pi_1o4_t64, HILO(y))
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

# ========================================== ^^^^^ =========================================

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

function rem2pi(x::DoubleFloat{Float64}, rounding::RoundingMode{:Nearest})
    abs(x) < onepi && return x
    w1 = mul323(inv_pi_2o1_t64, HILO(x))
    w2 = two_sum(w1[1] - round(w1[1]), w1[2], w1[3])
    y = mul322(pi_2o1_t64, w2)
    z = Double64(y)
    return z
end

rem2pi(x::DoubleFloat{Float64}, rounding::RoundingMode{:Down}) = mod2pi(x)
rem2pi(x::DoubleFloat{Float64}, rounding::RoundingMode{:Up}) = -rem2pi(-x, RoundDown)
rem2pi(x::DoubleFloat{Float64}, rounding::RoundingMode{:ToZero}) =
    signbit(x) ? rem2pi(x, RoundUp) : rem2pi(x, RoundDown)

rem2pi(x::DoubleFloat{Float32}, rounding::RoundingMode) =
    DoubleFloat{Float32}(rem2pi(DoubleFloat{Float64}(x), rounding))
rem2pi(x::DoubleFloat{Float16}, rounding::RoundingMode) =
    DoubleFloat{Float16}(rem2pi(DoubleFloat{Float64}(x), rounding))
