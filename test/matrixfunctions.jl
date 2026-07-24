const MFEPS = Double64(2.0)^-90       # comfortably above working precision

@testset "sylvester and lyap" begin
    A = Double64[2 1; 0 3]
    B = Double64[4 0; 1 5]
    C = Double64[1 2; 3 4]
    X = sylvester(A, B, C)
    @test eltype(X) == Double64                       # real data => real solution
    @test maximum(abs.(A*X + X*B + C)) < MFEPS
    # against the LAPACK Float64 route
    Xd = sylvester(Float64.(A), Float64.(B), Float64.(C))
    @test maximum(abs.(Float64.(X) - Xd)) < 1e-12

    # rectangular C (m != n)
    A3 = Double64[1 2 0; 0 3 1; 0 0 5]
    C32 = Double64[1 0; 2 1; 0 3]
    X32 = sylvester(A3, B, C32)
    @test size(X32) == (3, 2)
    @test maximum(abs.(A3*X32 + X32*B + C32)) < MFEPS

    # complex data
    Ac = Complex{Double64}[1+1im 2; 0 3-1im]
    Cc = Complex{Double64}[1 1im; 2 0]
    Xc = sylvester(Ac, B, Cc)
    @test maximum(abs.(Ac*Xc + Xc*B + Cc)) < MFEPS

    # lyap: A*X + X*A' + C = 0; symmetric C gives symmetric X
    S = Double64[3 1; 1 4]
    Cs = Double64[2 1; 1 2]
    Xl = lyap(S, Cs)
    @test maximum(abs.(S*Xl + Xl*S' + Cs)) < MFEPS
    @test maximum(abs.(Xl - Xl')) < MFEPS
    @test maximum(abs.(Float64.(Xl) - lyap(Float64.(S), Float64.(Cs)))) < 1e-12

    # shared spectrum => singular equation
    @test_throws SingularException sylvester(Double64[1 0; 0 2], Double64[-1 0; 0 -3], C)
    @test_throws DimensionMismatch sylvester(A, B, Double64[1 2 3; 4 5 6])
end

@testset "lq" begin
    for A in (Double64[1 2 3; 4 5 6],                 # wide
              Double64[1 2; 3 4; 5 6],                # tall
              Double64[1 2; 3 4],                     # square
              Complex{Double64}[1+1im 2 0; 3 4-2im 1im])
        F = lq(A)
        @test F isa LinearAlgebra.LQ
        L, Q = F                                       # destructuring
        QM = Matrix(F.Q)
        @test istril(F.L)
        @test maximum(abs.(F.L * QM - A)) < MFEPS
        @test maximum(abs.(QM * QM' - I)) < MFEPS      # orthonormal rows
    end
    # underdetermined solve through the factorization: A * x = b, minimum norm
    A = Double64[1 2 3; 4 5 6]
    b = Double64[1, 2]
    x = lq(A) \ b
    @test maximum(abs.(A * x - b)) < MFEPS
    @test maximum(abs.(Float64.(x) - (lq(Float64.(A)) \ Float64.(b)))) < 1e-12
end

@testset "exp: defective and hard cases" begin
    N = Double64[1 1; 0 1]                             # defective Jordan block
    E = exp(N)
    @test eltype(E) == Double64
    @test maximum(abs.(E - Double64(ℯ) .* N)) < MFEPS  # exp = e*[1 1; 0 1] exactly

    Z = Double64[0 1; 0 0]                             # nilpotent
    @test maximum(abs.(exp(Z) - (I + Z))) < MFEPS

    R = Double64[0 -1; 1 0]                            # complex-pair spectrum
    ER = exp(R)
    @test eltype(ER) == Double64                       # real result for real input
    c1, s1 = cos(Double64(1)), sin(Double64(1))
    @test maximum(abs.(ER - [c1 -s1; s1 c1])) < MFEPS  # rotation matrix, closed form

    A = Double64[2 1; 1 3] .* 40                       # large norm => deep squaring
    F = eigen(A)                                       # symmetric: eigen is reliable
    refE = F.vectors * Diagonal(exp.(F.values)) * F.vectors'
    @test maximum(abs.(exp(A) - refE)) < Double64(2.0)^-70 * maximum(abs.(refE))
    @test exp(zeros(Double64, 2, 2)) == I

    # complex matrix
    G = Complex{Double64}[1+1im 2; 0 1-1im]
    @test maximum(abs.(exp(G) * exp(-G) - I)) < MFEPS
end

@testset "sqrt/log: defective and branch cases" begin
    N = Double64[1 1; 0 1]
    S = sqrt(N)
    @test eltype(S) == Double64
    @test maximum(abs.(S - Double64[1 0.5; 0 1])) < MFEPS   # closed form
    @test maximum(abs.(S * S - N)) < MFEPS
    L = log(Double64[2 1; 0 2])
    @test eltype(L) == Double64
    @test maximum(abs.(L - [log(Double64(2)) 0.5; 0 log(Double64(2))])) < MFEPS
    @test maximum(abs.(exp(L) - Double64[2 1; 0 2])) < MFEPS

    A = Double64[2 1; 1 3]                             # SPD: real, eigen shortcut
    S = sqrt(A)
    @test eltype(S) == Double64
    @test maximum(abs.(S - S')) < MFEPS               # symmetric up to roundoff
    @test maximum(abs.(S * S - A)) < MFEPS
    @test maximum(abs.(exp(log(A)) - A)) < MFEPS

    B = Double64[-4 0; 0 9]                            # negative eigenvalue
    SB = sqrt(B)
    @test eltype(SB) == Complex{Double64}              # genuinely complex
    @test maximum(abs.(SB * SB - B)) < MFEPS
    LB = log(B)
    @test maximum(abs.(exp(LB) - B)) < MFEPS

    @test_throws SingularException log(Double64[1 0; 0 0])   # exactly singular

    # general nonsymmetric round trip
    M = Double64[1 2 0; -3 4 1; 0 1 2]
    @test maximum(abs.(sqrt(M)^2 - M)) < MFEPS
    @test maximum(abs.(exp(log(M)) - M)) < MFEPS

    # delegations
    @test maximum(abs.(log2(Double64[4 0; 0 8]) - [2 0; 0 3])) < MFEPS
    @test maximum(abs.(expm1(zeros(Double64, 2, 2)))) < MFEPS
    @test maximum(abs.(log1p(Double64[1 0; 0 3]) - log(Double64[2 0; 0 4]))) < MFEPS
end

@testset "trig/hyperbolic: identities, defective, realness" begin
    R = Double64[0 -1; 1 0]
    s, c = sincos(R)
    @test eltype(s) == Double64 && eltype(c) == Double64
    @test maximum(abs.(s*s + c*c - I)) < MFEPS         # sin^2 + cos^2 = I
    @test maximum(abs.(sin(R) - s)) < MFEPS && maximum(abs.(cos(R) - c)) < MFEPS

    N = Double64[3 1; 0 3]                             # defective
    s, c = sincos(N)
    @test maximum(abs.(s*s + c*c - I)) < MFEPS
    @test maximum(abs.(s - [sin(Double64(3)) cos(Double64(3)); 0 sin(Double64(3))])) < MFEPS
    @test maximum(abs.(tan(N) - s / c)) < MFEPS
    @test maximum(abs.(cosh(N)^2 - sinh(N)^2 - I)) < MFEPS
    @test maximum(abs.(tanh(N) * cosh(N) - sinh(N))) < MFEPS
    @test maximum(abs.(sec(N) * c - I)) < MFEPS

    # complex matrix identity
    G = Complex{Double64}[1im 1; 0 2]
    s, c = sincos(G)
    @test maximum(abs.(s*s + c*c - I)) < MFEPS

    # accuracy vs the diagonalizable eigen route on a symmetric matrix
    A = Double64[2 1; 1 3]
    F = eigen(A)
    ref = F.vectors * Diagonal(sin.(F.values)) * F.vectors'
    @test maximum(abs.(sin(A) - ref)) < MFEPS
end

@testset "scalar trig reduction windows" begin
    # the cos branch that fixes cancellation near pi/2 must not swallow
    # the rest of (pi/2, pi) -- its Taylor kernel needs |x - pi/2| <= pi/32
    setprecision(BigFloat, 256) do
        for x in (1.4, 1.47, 1.5, Float64(pi)/2, 1.65, 1.7, 2.0, 2.5, 3.0,
                  3.1, 3.14, Float64(pi), 3.2, 4.0, 5.0, 6.0)
            d = Double64(x)
            @test abs(BigFloat(cos(d)) - cos(BigFloat(d))) < 1.0e-30
            @test abs(BigFloat(sin(d)) - sin(BigFloat(d))) < 1.0e-30
        end
    end
end

@testset "matrix power realification" begin
    A = Double64[2 1; 1 3]
    P = A ^ Double64(2.5)
    @test eltype(P) == Double64                        # SPD => real power
    @test maximum(abs.(P * P - A^5)) < Double64(2.0)^-80
end
