@testset "Concrete Accuracy" begin
    zero_accurate = Double64(0.0)
    one_accurate  = Double64(1.0)

    pi_accurate   = Double64(pi)
    phi_accurate  = Double64(phi)

    @test pi_accurate   == DoubleFloat{Float64}(pi)

    @test abs(inv(inv(pi_accurate)) - pi_accurate) <= eps(LO(pi_accurate))
    @test abs(phi_accurate - (phi_accurate*phi_accurate - 1.0)) <= eps(LO(phi_accurate))

    a = Base.TwicePrecision(3.0) / Base.TwicePrecision(7.0)
    b = Double64(3.0) / Double64(7.0)
    c = Base.TwicePrecision(17.0) / Base.TwicePrecision(5.0)
    d = Double64(17.0) / Double64(5.0)

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


    @test zero(Double64) == Double64(0.0, 0.0)
    @test one(Double64) == Double64(1.0, 0.0)
    @test zero(Double32) == Double32(0.0f0, 0.0f0)
    @test one(Double32) == Double32(1.0f0, 0.0f0)

    @test round(Double64(123456.0, 1.0e-17), RoundUp) == Double64(123457.0, 0.0)
    @test round(Double64(123456.0, -1.0e-17), RoundUp) == Double64(123456.0, 0.0)
    @test round(Double64(123456.0, -1.0e-17), RoundDown) == Double64(123455.0, 0.0)

    @test typemax(Double64) == Double64(typemax(Float64))
    @test floatmin(Double32) == Double32(floatmin(Float32))

    @test isnan( nan(Double64) )
    @test isinf( inf(Double16) )

    @test typeof(rand(Double64)) == Double64
    @test typeof(rand(Double32)) == Double32
    @test typeof(rand(Double16)) == Double16
end
