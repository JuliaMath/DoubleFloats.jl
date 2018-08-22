@testset "precision" begin
    @test precision(Double64) == 113
    @test precision(Double32) == 53
    @test precision(Double32) == 24
end

@testset "maxintfloat" begin
    @test maxintfloat(Double64) >   maxintfloat(Double64) - 1
    @test maxintfloat(Double64) == (maxintfloat(Double64) - 1) + 1
    @test maxintfloat(Double32) >   maxintfloat(Double32) - 1
    @test maxintfloat(Double32) == (maxintfloat(Double32) - 1) + 1
    @test maxintfloat(Double16) >   maxintfloat(Double16) - 1
    @test maxintfloat(Double16) == (maxintfloat(Double16) - 1) + 1
end
