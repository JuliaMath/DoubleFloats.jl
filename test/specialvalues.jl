@testset "maxintfloat $T" for T in (Double32, Double64)
    @test isinteger(maxintfloat(T))

    # Previous integer is representable, next integer is not
    @test maxintfloat(T) == (maxintfloat(T) - one(T)) + one(T)
    @test maxintfloat(T) != (maxintfloat(T) + one(T)) - one(T)
end

# Double16 is a special case
@test isinteger(maxintfloat(Double16))
@test maxintfloat(Double16) == floatmax(Double16)


@testset "Inf and NaN generation $T" for T in (Double16, Double32, Double64)
    @test T(Inf) == inf(T)
    @test T(Inf) == posinf(T)
    @test T(-Inf) == neginf(T)
    @test T(NaN) == nan(T)
end
