@testset "maxintfloat $T" for T in (Double16, Double32, Double64)
    @test isinteger(maxintfloat(T))

    # Previous integer is representable, next integer is not
    @test maxintfloat(T) == (maxintfloat(T) - one(T)) + one(T)
    @test maxintfloat(T) != (maxintfloat(T) + one(T)) - one(T)
    
    @test maintfloat(T) < floatmax(T)
end


@testset "Inf and NaN generation $T" for T in (Double16, Double32, Double64)
    @test T(Inf) == inf(T)
    @test T(Inf) == posinf(T)
    @test T(-Inf) == neginf(T)
    @test T(NaN) == nan(T)

    @test T(Inf32) == inf(T)
    @test T(Inf32) == posinf(T)
    @test T(-Inf32) == neginf(T)
    @test T(NaN32) == nan(T)

    @test T(Inf16) == inf(T)
    @test T(Inf16) == posinf(T)
    @test T(-Inf16) == neginf(T)
    @test T(NaN16) == nan(T)
end
