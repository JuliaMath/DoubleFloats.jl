const twopi_df64  = Double64(6.283185307179586, 2.4492935982947064e-16)
const onepi_df64  = Double64(3.141592653589793, 1.2246467991473532e-16)
const halfpi_df64 = Double64(1.5707963267948966, 6.123233995736766e-17)
const qrtrpi_df64 = Double64(0.7853981633974483, 3.061616997868383e-17)

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


function mod2pi(x::DoubleFloat{Float64})
    signbit(x) && return mod2pi_neg(x)
    x < twopi_df64 && return x
    w1 = mul323(inv_pi_2o1_t64, HILO(x))
    w2 = add_2(w1[1] - trunc(Int,w1[1]), w1[2], w1[3])
    y = mul322(pi_2o1_t64, w2)
    z = Double64(y)
    return z
end

function mod2pi_neg(x::DoubleFloat{Float64})
    m = mod2pi(-x)
    return Double64(sub322(pi_2o1_t64, HILO(m)))
end

mod2pi(x::DoubleFloat{Float32}) = DoubleFloat{Float32}(mod2pi(DoubleFloat{Float64}(x)))
mod2pi(x::DoubleFloat{Float16}) = DoubleFloat{Float16}(mod2pi(DoubleFloat{Float64}(x)))

function modpi(x::DoubleFloat{Float64})
    signbit(x) && return modpi_neg(x)
    x < onepi_df64 && return x
    w1 = mul323(inv_pi1o1_t64, HILO(x))
    w2 = add_2(w1[1] - trunc(Int,w1[1]), w1[2], w1[3])
    y = mul322(pi1o1_t64, w2)
    z = Double64(y)
    return z
end

function modpi_neg(x::DoubleFloat{Float64})
    m = modpi(-x)
    return Double64(sub322(pi1o1_t64, HILO(m)))
end
modpi(x::DoubleFloat{Float32}) = DoubleFloat{Float32}(modpi(DoubleFloat{Float64}(x)))
modpi(x::DoubleFloat{Float16}) = DoubleFloat{Float16}(modpi(DoubleFloat{Float64}(x)))

function modpipm(x::DoubleFloat{Float64})
    abs(x) < onepi_df64 && return x
    w1 = mul323(inv_pi1o1_t64, HILO(x))
    w2 = add_2(w1[1] - trunc(Int,w1[1]), w1[2], w1[3])
    y = mul322(pi1o1_t64, w2)
    z = Double64(y)
    return z
end

modpipm(x::DoubleFloat{Float32}) = DoubleFloat{Float32}(modpipm(DoubleFloat{Float64}(x)))
modpipm(x::DoubleFloat{Float16}) = DoubleFloat{Float16}(modpipm(DoubleFloat{Float64}(x)))

function modhalfpi(x::DoubleFloat{Float64})
    signbit(x) && return modhalfpi_neg(x)
    x < halfpi_df64 && return x
    w1 = mul323(inv_pi1o2_t64, HILO(x))
    w2 = add_2(w1[1] - trunc(Int,w1[1]), w1[2], w1[3])
    y = mul322(pi1o2_t64, w2)
    z = Double64(y)
    return z
end

function modhalfpi_neg(x::DoubleFloat{Float64})
    m = modhalfpi(-x)
    return Double64(sub322(pi1o2_t64, HILO(m)))
end

modhalfpi(x::DoubleFloat{Float32}) = DoubleFloat{Float32}(modhalfpi(DoubleFloat{Float64}(x)))
modhalfpi(x::DoubleFloat{Float16}) = DoubleFloat{Float16}(modhalfpi(DoubleFloat{Float64}(x)))

function modhalfpipm(x::DoubleFloat{Float64})
    abs(x) < halfpi_df64 && return x
    w1 = mul323(inv_pi1o2_t64, HILO(x))
    w2 = add_2(w1[1] - trunc(Int,w1[1]), w1[2], w1[3])
    y = mul322(pi1o2_t64, w2)
    z = Double64(y)
    return z
end

modhalfpipm(x::DoubleFloat{Float32}) = DoubleFloat{Float32}(modhalfpipm(DoubleFloat{Float64}(x)))
modhalfpipm(x::DoubleFloat{Float16}) = DoubleFloat{Float16}(modhalfpipm(DoubleFloat{Float64}(x)))

function modqrtrpi(x::DoubleFloat{Float64})
    signbit(x) && return modqrtrpi_neg(x)
    x < qrtrpi_df64 && return x
    w1 = mul323(inv_pi1o4_t64, HILO(x))
    w2 = add_2(w1[1] - trunc(Int,w1[1]), w1[2], w1[3])
    y = mul322(pi1o4_t64, w2)
    z = Double64(y)
    return z
end

function modqrtrpi_neg(x::DoubleFloat{Float64})
    m = modqrtrpi(-x)
    return Double64(sub322(pi1o4_t64, HILO(m)))
end

modqrtrpi(x::DoubleFloat{Float32}) = DoubleFloat{Float32}(modqrtrpi(DoubleFloat{Float64}(x)))
modqrtrpi(x::DoubleFloat{Float16}) = DoubleFloat{Float16}(modqrtrpi(DoubleFloat{Float64}(x)))

function modqrtrpipm(x::DoubleFloat{Float64})
    abs(x) < qrtrpi_df64 && return x
    w1 = mul323(inv_pi1o4_t64, HILO(x))
    w2 = add_2(w1[1] - trunc(Int,w1[1]), w1[2], w1[3])
    y = mul322(pi1o4_t64, w2)
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

