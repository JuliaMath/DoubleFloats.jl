const twopi_df64  = DoubleF64(6.283185307179586, 2.4492935982947064e-16)
const onepi_df64  = DoubleF64(3.141592653589793, 1.2246467991473532e-16)
const halfpi_df64 = DoubleF64(1.5707963267948966, 6.123233995736766e-17)
const qrtrpi_df64 = DoubleF64(0.7853981633974483, 3.061616997868383e-17)

const twopi_tf64  = (6.283185307179586, 2.4492935982947064e-16, -5.989539619436679e-33)
const onepi_tf64  = (3.141592653589793, 1.2246467991473532e-16, -2.9947698097183397e-33)
const halfpi_tf64 = (1.5707963267948966, 6.123233995736766e-17, -1.4973849048591698e-33)
const qrtrpi_tf64 = (0.7853981633974483, 3.061616997868383e-17, -7.486924524295849e-34)

const invtwopi_tf64  = (0.15915494309189535, -9.839338337591243e-18, -5.360718141446502e-34)
const invonepi_tf64  = (0.3183098861837907, -1.9678676675182486e-17, -1.0721436282893004e-33)
const invhalfpi_tf64 = (0.6366197723675814, -3.935735335036497e-17, -2.1442872565786008e-33)
const invqrtrpi_tf64 = (1.2732395447351628, -7.871470670072994e-17, -4.2885745131572016e-33)


function mod2pi(x::DoubleFloat{Float64})
    signbit(x) && return twopi_df64 - mod2pi(-x)
    x < twopi_df64 && return x
    w1 = mul323(invtwopi_tf64, HILO(x))
    w2 = ((w1[1] - trunc(Int,w1[1]), w1[2], w1[3])
    y = mul332(twopi_tf64, w2)
    z = DoubleF64(y)
    return z
end

function modpi(x::DoubleFloat{Float64})
    signbit(x) && return onepi_df64 - modpi(-x)
    x < onepi_df64 && return x
    w1 = mul323(invonepi_tf64, HILO(x))
    w2 = ((w1[1] - trunc(Int,w1[1]), w1[2], w1[3])
    y = mul332(onepi_tf64, w2)
    z = DoubleF64(y)
    return z
end

function modhalfpi(x::DoubleFloat{Float64})
    signbit(x) && return halfpi_df64 - modhalfpi(-x)
    x < halfpi_df64 && return x
    w1 = mul323(invhalfpi_tf64, HILO(x))
    w2 = ((w1[1] - trunc(Int,w1[1]), w1[2], w1[3])
    y = mul332(halfpi_tf64, w2)
    z = DoubleF64(y)
    return z
end

function modqrtrpi(x::DoubleFloat{Float64})
    signbit(x) && return qrtrpi_df64 - modqrtrpi(-x)
    x < qrtrpi_df64 && return x
    w1 = mul323(invqrtrpi_tf64, HILO(x))
    w2 = ((w1[1] - trunc(Int,w1[1]), w1[2], w1[3])
    y = mul332(qrtrpi_tf64, w2)
    z = DoubleF64(y)
    return z
end
