using Test
using Base.MathConstants
using DoubleFloats

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
@test phi_accurate   == Double(phi)
@test phi_performant == FastDouble(phi)

invpi_accurate   = inv(pi_accurate)
invpi_performant = inv(pi_performant)
invphi_accurate   = inv(phi_accurate)
invphi_performant = inv(phi_performant)

@test inv(invpi_accurate) / pi_accurate = one_accurate
@test abs(inv(inv(pi_performant))-pi_performant) <= eps(LO(pi_performant))

@test abs(phi_accurate - (phi_accurate*phi_accurate - 1.0)) <= eps(LO(phi_accurate))


performant_sqrt2   = Double{Accurate,Float64}(sqrt2)
performant_sqrt2bf = Double{Accurate,Float64}(sqrt2bf)

y = 0.1
by = big(y)
sy = Single(y)
dy = Double(y)

@test x == sx == dx
@test y == sy == dy

@test zero(Double{Float64}) == Double(0.0, 0.0)
@test one(Double{Float64}) == Double(1.0, 0.0)
@test zero(Double(0.0, 0.0)) == Double(0.0, 0.0)
@test one(Double(0.0, 0.0)) == Double(1.0, 0.0)

dxy = dx*dy
bxy = bx*by
@test sx*sy == dxy
@test x*y == Float64(dxy)
@test dxy == Double(bxy)

@test x+y == Float64(dx+dy)
@test dx+dy == Double(bx+by)

@test x-y == Float64(dx-dy)
@test dx-dy == Double(bx-by)

@test x/y == Float64(dx/dy)
@test dx/dy == Double(bx/by)

@test sqrt(y) == Float64(sqrt(dy))
@test sqrt(dy) == Double(sqrt(by))

#@test rem(dxy,1.0) == Double(rem(bxy,1.0))


## New
@test Double(pi) == Double{Float64}(3.141592653589793, 1.2246467991473532e-16)
@test Double(3.5) == Double{Float64}(3.5, 0.0)
@test Double(3.5) == Double{Float64}(3.5, 0.0)

a = Double(big"3.1")
@test a == Double(3.1, -8.881784197001253e-17)
@test BigFloat(a) == big"3.099999999999999999999999999999995069619342368676216176696466982586064542459781"

@test Single(3) === Single(3.0)
@test Double(3) === Double(3.0, 0.0)
@test Double(big(3)) === Double(3.0, 0.0)

@test convert(Single{Float64}, 1) === Single(1.0)
@test convert(Single{Float32}, 1) === Single(1.0f0)
@test convert(Double{Float64}, 1) === Double(1.0, 0.0)
@test convert(Double{Float32}, 1) === Double(1.0f0, 0.0f0)

@test Single{Float32}(3) === Single{Float32}(3.0f0)
@test Double{Float32}(3) === Double{Float32}(3.0f0, 0.0f0)
@test Single{Float32}(BigFloat(3)) === Single{Float32}(3.0f0)
@test Double{Float32}(BigFloat(3)) === Double{Float32}(3.0f0, 0.0f0)
@test true
