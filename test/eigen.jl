const D64EPS = Double64(2.0)^-100    # comfortably above the ~2^-104 working precision

function eigresidual(A, F)
    V, d = F.vectors, F.values
    maximum(abs.(A * V - V * Diagonal(d)))
end

@testset "eigen: real symmetric" begin
    A = Double64[2 1; 1 3]
    F = eigen(A)
    @test eltype(F.values) == Double64            # hermitian input => real spectrum
    @test eltype(F.vectors) == Double64
    @test issorted(F.values)
    @test eigresidual(A, F) < D64EPS
    @test maximum(abs.(F.vectors' * F.vectors - I)) < D64EPS   # orthonormal
    # golden values for [2 1; 1 3]: (5 ∓ sqrt(5))/2
    @test abs(F.values[1] - (5 - sqrt(Double64(5)))/2) < D64EPS
    @test abs(F.values[2] - (5 + sqrt(Double64(5)))/2) < D64EPS
end

@testset "eigen: wrappers (Symmetric/Hermitian)" begin
    A = Double64[4 1 0; 1 5 2; 0 2 6]
    F = eigen(Symmetric(A))
    @test eltype(F.values) == Double64
    @test eigresidual(A, F) < D64EPS
    @test sort(F.values) == F.values
    @test eigvals(Symmetric(A)) ≈ F.values

    C = Complex{Double64}[3 1im 0; -1im 4 1; 0 1 5]
    Fh = eigen(Hermitian(C))
    @test eltype(Fh.values) == Double64           # hermitian => real eigenvalues
    @test eltype(Fh.vectors) == Complex{Double64}
    @test eigresidual(C, Fh) < D64EPS
    @test maximum(abs.(Fh.vectors' * Fh.vectors - I)) < D64EPS
    @test eigvals(Hermitian(C)) ≈ Fh.values
end

@testset "eigen: real general, real spectrum" begin
    # triangular => spectrum is the diagonal, exactly real
    A = Double64[1 2 3; 0 4 5; 0 0 6]
    F = eigen(A)
    @test eltype(F.values) == Double64            # realified, like the LAPACK route
    @test eltype(F.vectors) == Double64
    @test F.values ≈ Double64[1, 4, 6]
    @test eigresidual(A, F) < D64EPS
    @test eigvals(A) isa Vector{Double64}
    @test eigvals(A) ≈ F.values
end

@testset "eigen: real general, complex spectrum" begin
    R = Double64[0 -1; 1 0]                        # eigenvalues ±im
    F = eigen(R)
    @test eltype(F.values) == Complex{Double64}
    @test F.values[1] ≈ -im && F.values[2] ≈ im    # sorted by (real, imag)
    @test eigresidual(R, F) < D64EPS

    B = Double64[1 2 0; -3 4 1; 0 1 2]
    F = eigen(B)
    @test eigresidual(B, F) < D64EPS
    @test eigvals(B) ≈ F.values
end

@testset "eigen: complex general" begin
    G = Complex{Double64}[1+1im 2 0; 3 4-2im 1; 0 1im 2]
    F = eigen(G)
    @test eltype(F.values) == Complex{Double64}
    @test eigresidual(G, F) < D64EPS
    @test all(abs(norm(F.vectors[:, j]) - 1) < D64EPS for j in axes(F.vectors, 2))
    @test eigvals(G) ≈ F.values
end

@testset "eigen: random matrices, residual + accuracy vs BigFloat" begin
    setprecision(BigFloat, 256) do
        Random.seed!(2077)
        for n in (1, 2, 5)
            A = rand(Double64, n, n) .- 0.5
            F = eigen(A)
            @test eigresidual(A, F) < n * D64EPS
            # eigenvalues against a BigFloat reference (GenericSchur route)
            ref = eigvals(BigFloat.(A))
            got = sort(Complex{BigFloat}.(F.values), by = x -> (real(x), imag(x)))
            ref = sort(Complex{BigFloat}.(ref), by = x -> (real(x), imag(x)))
            @test maximum(abs.(got .- ref)) < 1.0e-28

            S = A + transpose(A)                   # symmetric
            Fs = eigen(S)
            @test eltype(Fs.values) == Double64
            @test eigresidual(S, Fs) < n * D64EPS
            @test maximum(abs.(Fs.vectors' * Fs.vectors - I)) < n * D64EPS
        end
    end
end

@testset "eigen: kwargs and edge cases" begin
    A = Double64[1 2; 3 4]
    F = eigen(A; sortby = x -> -real(x))           # custom sort honored
    @test real(F.values[1]) >= real(F.values[2])
    @test eigresidual(A, F) < D64EPS

    F1 = eigen(fill(Double64(7), 1, 1))            # 1x1
    @test F1.values ≈ [7] && F1.vectors ≈ fill(1, 1, 1)

    @test_throws DimensionMismatch eigen(Double64[1 2 3; 4 5 6])
end

@testset "eigen: matrixfunction round trips" begin
    A = Double64[2 1; 1 3]                         # SPD: log is real-safe
    @test maximum(abs.(exp(log(A)) - A)) < 1.0e-25
    B = Double64[-2 0; 0 3]                        # negative eigenvalue: complex path
    LB = log(B)
    @test eltype(LB) == Complex{Double64}
    @test maximum(abs.(exp(LB) - B)) < 1.0e-25
end
