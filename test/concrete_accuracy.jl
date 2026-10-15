@testset "Concrete Accuracy" begin
    zero_accurate = Double64(0.0)
    one_accurate  = Double64(1.0)

    pi_accurate   = Double64(pi)
    phi_accurate  = Double64(phi)

    @test pi_accurate   == DoubleFloat{Float64}(pi)

    @test abs(inv(inv(pi_accurate)) - pi_accurate) <= eps(LO(pi_accurate))
    @test abs(phi_accurate - (phi_accurate*phi_accurate - 1.0)) <= 3eps(LO(phi_accurate))

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

@testset "cbrt returns a DoubleFloat" begin
    for D in (Double64, Double32, Double16)
        for v in (8, 2, 27, 0.001, -27)
            x = D(v)
            r = cbrt(x)
            @test r isa D
            @test abs(r^3 - x) <= 8 * eps(D) * abs(x)
        end
        @test cbrt(D(8)) == 2
        @test cbrt(D(-27)) == -3
        @test cbrt(D(0)) isa D && iszero(cbrt(D(0)))
        @test cbrt(D(Inf)) isa D && isinf(cbrt(D(Inf)))
        @test cbrt(D(NaN)) isa D && isnan(cbrt(D(NaN)))
        # the result can be used in arithmetic, e.g. a tolerance of the form cbrt(eps(T))^2
        @test cbrt(eps(D))^2 isa D
    end
end

@testset "Subnormal numbers" begin
    for (F, D) in (
        (Float64, Double64),
        (Float32, Double32),
        (Float16, Double16),
    )
        # NOTE: using `prevfloat(floatmin(F))` doesn't expose `sqrt(D(sn))` returning a `NaN`
        sn = D(floatmin(F) / 10)

        @test issubnormal(sn)
        @test sqrt(F(sn)) == F(sqrt(D(sn)))
        @test cbrt(F(sn)) == F(cbrt(D(sn)))
    end
end
