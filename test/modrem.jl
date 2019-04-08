@testset "modpi" begin
    x=cbrt(41)*sqrt(Double64(pi))
    @test DoubleFloats.mod2pi(x) == Double64(6.111805926475162, -1.667563077572613e-16)
    @test DoubleFloats.mod1pi(x) == Double64(2.9702132728853683, 1.54868222178066e-16)
    @test DoubleFloats.modhalfpi(x) == Double64(1.3994169460904717,  9.363588222069835e-17)
    @test DoubleFloats.modqrtrpi(x) == Double64(0.6140187826930236, -4.8002590220501136e-17)
end

@testset "rempi" begin
    x=cbrt(41)*sqrt(Double64(pi))
    @test DoubleFloats.rem2pi(x) == Double64(6.111805926475162, -1.667563077572613e-16)
    @test DoubleFloats.rem1pi(x) == Double64(2.9702132728853683, 1.54868222178066e-16)
    @test DoubleFloats.rem2pi(-x) == Double64(-6.111805926475162, 1.667563077572613e-16)
    @test DoubleFloats.rem1pi(-x) == Double64(-2.9702132728853683, -1.54868222178066e-16)
end
