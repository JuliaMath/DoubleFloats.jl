using Test
using Base.MathConstants
using DoubleFloats

using Compat
using Compat.Test
using AccurateArithmetic

if VERSION >= v"0.7.0-"
  using Random
end

srand(1602)
include("bigfloats.jl")
include("randfloats.jl")

zero_accurate = Double{Float64, Accuracy}(0.0)
zero_performant = Double{Float64, Performance}(0.0)
one_accurate = Double{Float64, Accuracy}(1.0)
one_performant = Double{Float64, Performance}(1.0)

pi_accurate   = Double{Float64, Accuracy}(pi)
pi_performant = Double{Float64, Performance}(pi)
phi_accurate   = Double{Float64, Accuracy}(golden)
phi_performant = Double{Float64, Performance}(golden)

@test pi_accurate   == Double(pi)
@test pi_performant == FastDouble(pi)

@test abs(inv(inv(pi_accurate)) - pi_accurate) <= eps(LO(pi_accurate))
@test abs(inv(inv(pi_performant)) - pi_performant) <= eps(LO(pi_performant))
@test abs(phi_accurate - (phi_accurate*phi_accurate - 1.0)) <= eps(LO(phi_accurate))

a = Base.TwicePrecision(3.0) / Base.TwicePrecision(7.0)
b = Double{Float64, Accuracy}(3.0) / Double{Float64, Accuracy}(7.0)
c = Base.TwicePrecision(17.0) / Base.TwicePrecision(5.0)
d = Double{Float64, Accuracy}(17.0) / Double{Float64, Accuracy}(5.0)

@test a.hi == b.hi
@test a.lo == b.lo
@test (a+c).hi == (b+d).hi
@test (a+c).lo == (b+d).lo
@test (a-c).hi == (b-d).hi
@test abs((a-c).lo - (b-d).lo) <= eps((a-c).lo)
@test (a*c).hi == (b*d).hi
@test (a*c).lo == (b*d).lo
@test (a/c).hi == (b/d).hi
@test (a/c).lo == (b/d).lo


@test zero(Double{Float64}) == Double(0.0, 0.0)
@test one(Double{Float64}) == Double(1.0, 0.0)
@test zero(Double(0.0, 0.0)) == Double(0.0, 0.0)
@test one(Double(0.0, 0.0)) == Double(1.0, 0.0)

