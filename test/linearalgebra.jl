@testset "linear algebra" begin
    @test issquare(reshape(rand(Double32,3*3), 3, 3))

    # issue #77
    M = Double64.([1 0; 1 1])
    @test_throws ErrorException exp(M)
    M = Complex{Double64}.([1 0; 1 1])
    @test_throws ErrorException exp(M)
end
