"""
    x_minus_onepi(x) is x - π
"""
x_minus_onepi

"""
    x_minus_halfpi(x) is x - π/2
"""
x_minus_halfpi

"""
    x_minus_qrtrpi(x) is x - π/4
"""
x_minus_qrtrpi

x_minus_onepi(x::DoubleFloat{Float64}) = x_minus_onepi(HI(x), LO(x))
x_minus_halfpi(x::DoubleFloat{Float64}) = x_minus_halfpi(HI(x), LO(x))
x_minus_qrtrpi(x::DoubleFloat{Float64}) = x_minus_qrtrpi(HI(x), LO(x))

# Each constant is carried as a triple-double (c1 + c2 + c3).  The small
# pieces are recombined with error-free sums so that the result keeps full
# *relative* accuracy even when it is tiny (x very close to the constant);
# a plain `zlo += t7` would round at ulp(t7) ~ 2^-109 and cap the result's
# absolute accuracy there.

const _trig_halfpi = (1.57079632679489660, 6.1232339957367660e-17, -1.4973849048591698e-33)
const _trig_pi = (3.14159265358979300, 1.2246467991473532e-16, -2.9947698097183397e-33)
const _trig_threehalfpi = (4.71238898038469, 1.8369701987210297e-16, 7.8337969295008e-33)
const _trig_twopi = (6.283185307179586, 2.4492935982947064e-16, -5.989539619436679e-33)

# The last constant already carries the sign used in recombination.
@inline function _trig_subtract(hi, lo, c, diff::F, sum::G) where {F,G}
    zhi, t1 = diff(c[1], hi)
    t2, t3 = diff(c[2], lo)
    t7, t4 = sum(t1, t2)
    t5 = t3 + t4
    u1, u2 = sum(t7, t5 + c[3])
    s1, e1 = sum(zhi, u1)
    return unsafe_double(Float64, -s1, -(e1 + u2))
end

x_minus_onepi(hi::Float64, lo::Float64) = _trig_subtract(hi, lo, _trig_pi, two_diff, two_sum)
x_minus_halfpi(hi::Float64, lo::Float64) = _trig_subtract(hi, lo, _trig_halfpi, two_diff, two_sum)

x_minus_threehalfpi(x::DoubleFloat{Float64}) = x_minus_threehalfpi(HI(x), LO(x))
x_minus_twopi(x::DoubleFloat{Float64}) = x_minus_twopi(HI(x), LO(x))

x_minus_threehalfpi(hi::Float64, lo::Float64) = _trig_subtract(hi, lo, _trig_threehalfpi, two_diff, two_sum)
x_minus_twopi(hi::Float64, lo::Float64) = _trig_subtract(hi, lo, _trig_twopi, two_diff, two_sum)

function x_minus_qrtrpi(hi::T, lo::T) where {T<:Float64}
    zhi, t1 = two_diff(0.78539816339744830, hi)
    t2, t3 = two_diff(3.0616169978683830e-17, lo)
    t7, t4 = two_sum(t1, t2)
    t5 = t3 + t4
    u1, u2 = two_sum(t7, t5 - 7.4869245242958490e-34)
    s1, e1 = two_sum(zhi, u1)
    return unsafe_double(Float64, -s1, -(e1 + u2))
end
