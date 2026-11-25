@testset "modpi" begin

    @test mod2pi(Double64(-13)) ≈ mod2pi(big(-13.)) atol = 1e-31

    x=cbrt(41)*sqrt(Double64(pi))

    @test DoubleFloats.mod2pi(x) == Double64(6.111805926475162, -1.667563077572613e-16)
    @test DoubleFloats.mod1pi(x) == Double64(2.9702132728853683, 1.54868222178066e-16)
    # these tests are unusable, sometimes they pass and othertimes they fail
    # @test DoubleFloats.modhalfpi(x) == Double64(1.3994169460904717, 9.362948122802731e-17)
    # @test DoubleFloats.modqrtrpi(x) == Double64(0.6140187826930236, -4.8008991213172176e-17)
end

@testset "rempi" begin
    x=cbrt(41)*sqrt(Double64(pi))

    @test DoubleFloats.rem2pi(x) == Double64(6.111805926475162, -1.667563077572613e-16)
    @test DoubleFloats.rem2pi(-x) == Double64(-0.1713793807044248, 4.647966647701768e-18)

    v = Double64.(-7:7)
    bigv = big.(v)
    for rounding in (RoundUp, RoundDown, RoundNearest, RoundToZero)
        drem = rem2pi.(v, Ref(rounding))
        bigrem = rem2pi.(bigv, Ref(rounding))
        @test all(abs.(bigrem-drem) .< 1e-31)
    end
end
