
zero_accurate = DoubleF64(0.0)
one_accurate  = DoubleF64(1.0)

pi_accurate   = DoubleF64(pi)
phi_accurate  = DoubleF64(phi)

@test pi_accurate   == DoubleFloat{Float64}(pi)

@test abs(inv(inv(pi_accurate)) - pi_accurate) <= eps(LO(pi_accurate))
@test abs(phi_accurate - (phi_accurate*phi_accurate - 1.0)) <= eps(LO(phi_accurate))

a = Base.TwicePrecision(3.0) / Base.TwicePrecision(7.0)
b = DoubleF64(3.0) / DoubleF64(7.0)
c = Base.TwicePrecision(17.0) / Base.TwicePrecision(5.0)
d = DoubleF64(17.0) / DoubleF64(5.0)

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


@test zero(DoubleF64) == DoubleF64(0.0, 0.0)
@test one(DoubleF64) == DoubleF64(1.0, 0.0)
@test zero(DoubleF32) == DoubleF32(0.0f0, 0.0f0)
@test one(DoubleF32) == DoubleF32(1.0f0, 0.0f0)

@test round(DoubleF64(123456.0, 1.0e-17), RoundUp) == DoubleF64(123457.0, 0.0)
@test round(DoubleF64(123456.0, -1.0e-17), RoundUp) == DoubleF64(123456.0, 0.0)
@test round(DoubleF64(123456.0, -1.0e-17), RoundDown) == DoubleF64(123455.0, 0.0)

@test typemax(DoubleF64) == DoubleF64(typemax(Float64))
@test realmin(DoubleF32) == DoubleF32(realmin(Float32))

@test isnan( nan(DoubleF64) )
@test isinf( inf(DoubleF16) )

@test typeof(rand(DoubleF64)) == DoubleF64
@test typeof(rand(DoubleF32)) == DoubleF32
@test typeof(rand(DoubleF16)) == DoubleF16
