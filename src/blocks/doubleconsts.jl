Double{Float64,E}(k_exp1) where {E<:Emphasis} =
    Double(E, 2.718281828459045, 1.4456468917292502e-16)
Double{Float64,E}(k_expneg1) where {E<:Emphasis} =
    Double(E, 0.36787944117144233, -1.2428753672788363e-17)
Double{Float64,E}(k_log2) where {E<:Emphasis} =
    Double(E, 0.6931471805599453, 2.3190468138462996e-17)
Double{Float64,E}(k_log10) where {E<:Emphasis} =
    Double(E, 2.302585092994046, -2.1707562233822494e-16)
Double{Float64,E}(k_log2of10) where {E<:Emphasis} =
    Double(E, 3.321928094887362, 1.661617516973592e-16)
Double{Float64,E}(k_log10of2) where {E<:Emphasis} =
    Double(E, 0.3010299956639812, -2.8037281277851704e-18)

Double{Float64,E}(k_pi) where {E<:Emphasis} =
    Double(E, 3.141592653589793, 1.2246467991473532e-16)
Double{Float64,E}(k_1pi) where {E<:Emphasis} =
    Double(E, 3.141592653589793, 1.2246467991473532e-16)
Double{Float64,E}(k_2pi) where {E<:Emphasis} =
    Double(E, 6.283185307179586, 2.4492935982947064e-16)
Double{Float64,E}(k_3pi) where {E<:Emphasis} =
    Double(E, 9.42477796076938, 3.6739403974420594e-16)
Double{Float64,E}(k_4pi) where {E<:Emphasis} =
    Double(E, 12.566370614359172, 4.898587196589413e-16)

Double{Float64,E}(k_invpi) where {E<:Emphasis} =
    Double(E, 0.3183098861837907, -1.9678676675182486e-17)
Double{Float64,E}(k_inv1pi) where {E<:Emphasis} =
    Double(E, 0.3183098861837907, -1.9678676675182486e-17)
Double{Float64,E}(k_inv2pi) where {E<:Emphasis} =
    Double(E, 0.15915494309189535, -9.839338337591243e-18)
Double{Float64,E}(k_inv3pi) where {E<:Emphasis} =
    Double(E, 0.1061032953945969, -6.559558891727496e-18)
Double{Float64,E}(k_inv4pi) where {E<:Emphasis} =
    Double(E, 0.07957747154594767, -4.9196691687956215e-18)

Double{Float64,E}(k_2invpi) where {E<:Emphasis} =
    Double(E, 0.6366197723675814, -3.935735335036497e-17)
Double{Float64,E}(k_4invpi) where {E<:Emphasis} =
    Double(E, 1.2732395447351628, -7.871470670072994e-17)


const k_1pi6  = :k_1pi6  # 0.52..
const k_2pi3  = :k_2pi3  # 2.09..
const k_5pi6  = :k_5pi3  # 2.61..

const k_pipow2 = :k_pipow2 # 9.86..
const k_pipow3 = :k_pipow3 # 31.0..
const k_pipow4 = :k_pipow4 # 97.4..
const k_invpipow2 = :k_invpipow2 # 0.10..
const k_invpipow3 = :k_invpipow3 # 0.03..
const k_invpipow4 = :k_invpipow4 # 0.01..

# [6//89, 31//89, 58//89, 83//89] .* pi (values for which sin(x), cos(x) are well tabled)
# [0.06744, 0.3484, 0.6520, 0.9326] (approx)
const k_6pi89  = :k_6pi89
const k_31pi89 = :k_31pi89
const k_58pi89 = :k_58pi89
const k_83pi89 = :k_83pi89

