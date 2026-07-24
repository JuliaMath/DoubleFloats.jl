using SpecialFunctions

@testset "special functions" begin
    # The intention here is not to check the accuracy of the libraries,
    # rather the sanity of library calls:
    piq = Double64(pi)
    halfq = Double64(0.5)
    @test gamma(halfq) ≈ sqrt(piq)
    for func in (erf, erfc, besselj0, besselj1, bessely0, bessely1, loggamma)
        @test func(halfq) ≈ func(0.5)
    end
    for func in (bessely, besselj)
        @test func(3,halfq) ≈ func(3,0.5)
    end
    a, b = Double64(2), Double64(b)
    @test gamma(a, b) ≈ gamma(2,3)
    @test all(logabsgamma(Double64(-0.5)) .≈ logabsgamma(-0.5))
    @test all(logabsgamma(Double64(-1.5)) .≈ logabsgamma(-1.5))
end
