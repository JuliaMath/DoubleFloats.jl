using GenericLinearAlgebra, GenericSchur

@testset "linear algebra" begin
    @test issquare(reshape(rand(Double32,3*3), 3, 3))

    # issue #77: exp of a defective (non-diagonalizable) matrix.
    # formerly threw "matrix is not diagonalizable"; the scaling-and-squaring
    # implementation handles it: exp([1 0; 1 1]) == e .* [1 0; 1 1]
    M = Double64.([1 0; 1 1])
    @test maximum(abs.(exp(M) - Double64(ℯ) .* M)) < Double64(2.0)^-90
    M = Complex{Double64}.([1 0; 1 1])
    @test maximum(abs.(exp(M) - Complex{Double64}(ℯ) .* M)) < Double64(2.0)^-90

    # Matrix functions should use one paired eigendecomposition and solve on
    # the right, rather than a separate eigenvalue solve and explicit inverse.
    M = Double64.([1.0 2.0; 3.0 4.0])
    @test isapprox(Float64.(exp(M)), exp([1.0 2.0; 3.0 4.0]), rtol=1e-13)
    @test isapprox(Float64.(sin(M)), sin([1.0 2.0; 3.0 4.0]), rtol=1e-13)
    sinM, cosM = sincos(M)
    @test sinM == sin(M)
    @test cosM == cos(M)

    CM = Complex{Double64}.([1.0 + 0.5im 2.0 - 1.0im;
                              -0.25 + 1.0im 0.75 - 0.5im])
    CM64 = ComplexF64.([1.0 + 0.5im 2.0 - 1.0im;
                         -0.25 + 1.0im 0.75 - 0.5im])
    @test isapprox(ComplexF64.(exp(CM)), exp(CM64), rtol=1e-13)
        
    t=[Complex{Double64}(1.0,0.0) Complex{Double64}(0.0,1.0);
       Complex{Double64}(0.0,-1.0) Complex{Double64}(1.0,0.0)]
    @test ishermitian(t)

    @test norm(Complex{Double64}[2, 2im]) ≈ norm(ComplexF64[2, 2im])
    @test norm(Complex{Double64}[2, 2im]) isa Double64

    @test norm(Complex{Double64}[2, 2im], 3.0) ≈ norm(ComplexF64[2, 2im], 3.0)
    @test norm(Complex{Double64}[2, 2im], 3.0) isa Double64

    @test norm(Double64[2, 1]) ≈ norm(Float64[2, 1])
    @test norm(Double64[2, 1], 3.0) ≈ norm(Float64[2, 1], 3.0)

    # issue #159
    @test norm(Double64[-1, -1], 1) ≈ 2

    # issue #105
    for T in [Double16, Double32, Double64]
        for p in [0, 1.0, 2.0, Inf, -Inf]
            @test norm(T[], p) == zero(T)
            @test norm(Complex{T}[], p) == zero(T)

            @test normalize(T[]) == T[]
            @test normalize(Complex{T}[]) == Complex{T}[]
        end
    end
end
