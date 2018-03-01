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





const k_pi    = :k_pi    # 3.14...
const k_2pi   = :k_2pi   # 6.28..
const k_3pi   = :k_3pi   # 9.42..
const k_4pi   = :k_2pi   # 12.4..
const k_1pi2  = :k_1pi2  # 1.57..
const k_1pi3  = :k_1pi3  # 1.04..
const k_1pi4  = :k_1pi4  # 0.78..
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

