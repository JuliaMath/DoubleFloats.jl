@testset "maxintfloat $T" for T in (Double32, Double64)
    @test isinteger(maxintfloat(T))

    # Previous integer is representable, next integer is not
    @test maxintfloat(T) == (maxintfloat(T) - one(T)) + one(T)
    @test maxintfloat(T) != (maxintfloat(T) + one(T)) - one(T)
end

# Double16 is a special case
@test isinteger(maxintfloat(Double16))
@test maxintfloat(Double16) == floatmax(Double16)
