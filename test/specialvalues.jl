@testset "maxintfloat $T" for T in (Double32, Double64)
    @test maxintfloat(T) == maxintfloat(T) + one(T)
    @test maxintfloat(T) != maxintfloat(T) - one(T)
end