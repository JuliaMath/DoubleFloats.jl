@testset "Basics" begin
    @test precision(Double64) == 113
    @test precision(Double32) == 53
    @test precision(Double32) == 24
end
