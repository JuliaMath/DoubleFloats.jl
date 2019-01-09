@testset "maxintfloat $T" for T in (Double16, Double32, Double64)
    @test isinteger(maxintfloat(T))

    # Previous integer is representable, next integer is not
    @test maxintfloat(T) == (maxintfloat(T) - one(T)) + one(T)
    @test maxintfloat(T) != (maxintfloat(T) + one(T)) - one(T)
    
    @test maxintfloat(T) < floatmax(T)
end


@testset "Inf and NaN generation $T" for T in (Double16, Double32, Double64)
    @test isinf(T(Inf)) == isinf(inf(T))
    @test isinf(T(Inf)) == isposinf(posinf(T))
    @test isinf(T(-Inf)) == isneginf(neginf(T))
    @test isnan(T(NaN)) == isnan(nan(T))

    @test isinf(T(Inf32)) == isinf(inf(T))
    @test isinf(T(Inf32)) == isposinf(posinf(T))
    @test isinf(T(-Inf32)) == isneginf(neginf(T))
    @test isnan(T(NaN32)) == isnan(nan(T))

    @test isinf(T(Inf16)) == isinf(inf(T))
    @test isinf(T(Inf16)) == isposinf(posinf(T))
    @test isinf(T(-Inf16)) == isneginf(neginf(T))
    @test isnan(T(NaN16)) == isnan(nan(T))
end

@testset "Inf and NaN layout $T" for T in (Double16, Double32, Double64)
    @test isinf(HI(T(Inf)))
    @test isnan(HI(T(NaN)))
    @test isnan(LO(T(Inf)))
    @test isnan(LO(T(NaN)))
end
