@testset "test support" begin
    # SplitMix64 reference outputs for seed 0 (Vigna's reference implementation).
    g = SplitMix64(0)
    @test next!(g) == 0xe220a8397b1dcdaf
    @test next!(g) == 0x6e789e6aa1b965f4
    @test next!(g) == 0x06c45d188009454f
    g = SplitMix64(1234567)
    @test next!(g) == 6457827717110365317
    @test next!(g) == 3203168211198807973
    @test 0.0 <= unitfloat!(SplitMix64(1)) < 1.0

    @test workingunit(Double64) == 2.0^-104
    @test workingunit(Double32) == 2.0^-46
    x = Double64(1.0, 2.0^-200)
    @test exactbig(x) == big(1.0) + big(2.0)^-200
    @test exactbig(Double64(Inf)) == Inf
    @test relerr(Double64(1.0), big(1.0)) == 0.0
    @test relerr(Double64(1.0, 2.0^-104), big(1.0)) == 1.0
end
