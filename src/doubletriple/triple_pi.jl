"""
    x_minus_onepi(x) is x - π
""" x_minus_onepi

"""
    x_minus_halfpi(x) is x - π/2
""" x_minus_halfpi

"""
    x_minus_qrtrpi(x) is x - π/4
""" x_minus_qrtrpi

x_minus_onepi(x::DoubleFloat{Float64}) = x_minus_onepi(HI(x), LO(x))
x_minus_halfpi(x::DoubleFloat{Float64}) = x_minus_halfpi(HI(x), LO(x))
x_minus_qrtrpi(x::DoubleFloat{Float64}) = x_minus_qrtrpi(HI(x), LO(x))

function x_minus_onepi(hi::T, lo::T) where {T<:Float64}
    zhi, t1 = two_diff(3.14159265358979300, hi)
    t2, t3 = two_diff(1.2246467991473532e-16, lo)
    t7, t4 = two_sum(t1, t2)
    t5 = t3 + t4
    zlo = t5 - 2.9947698097183397e-33
    zlo += t7
    return DoubleFloat{Float64}(-zhi, -zlo)
end

function x_minus_halfpi(hi::T, lo::T) where {T<:Float64}
    zhi, t1 = two_diff(1.57079632679489660, hi)
    t2, t3 = two_diff(6.1232339957367660e-17, lo)
    t7, t4 = two_sum(t1, t2)
    t5 = t3 + t4
    zlo = t5 - 1.4973849048591698e-33
    zlo += t7
    return DoubleFloat{Float64}(-zhi, -zlo)
end

function x_minus_qrtrpi(hi::T, lo::T) where {T<:Float64}
    zhi, t1 = two_diff(0.78539816339744830, hi)
    t2, t3 = two_diff(3.0616169978683830e-17, lo)
    t7, t4 = two_sum(t1, t2)
    t5 = t3 + t4
    zlo = t5 - 7.4869245242958490e-34
    zlo += t7
    return DoubleFloat{Float64}(-zhi, -zlo)
end
