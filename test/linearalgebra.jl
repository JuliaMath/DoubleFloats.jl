@testset "linear algebra" begin
    @test issquare(reshape(rand(Double32,3*3), 3, 3))
end
