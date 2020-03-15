@testset "linear algebra" begin
    @test issquare(reshape(rand(Double32,3*3), 3, 3))

    # issue #77
    M = Double64.([1 0; 1 1])
    @test_throws ErrorException exp(M)
    M = Complex{Double64}.([1 0; 1 1])
    @test_throws ErrorException exp(M)
    
    t=[Complex{Double64}(1.0,0.0) Complex{Double64}(0.0,1.0);
       Complex{Double64}(0.0,-1.0) Complex{Double64}(1.0,0.0)]
    @test ishermitian(t)

    @test norm(Complex{Double64}[2, 2im]) ≈ norm(ComplexF64[2, 2im])
    @test norm(Complex{Double64}[2, 2im]) isa Double64

    @test norm(Complex{Double64}[2, 2im], 3.0) ≈ norm(ComplexF64[2, 2im], 3.0)
    @test norm(Complex{Double64}[2, 2im], 3.0) isa Double64

    @test norm(Double64[2, 1]) ≈ norm(Float64[2, 1])
    @test norm(Double64[2, 1], 3.0) ≈ norm(Float64[2, 1], 3.0)
end
