# testing corner cases brought to light by KlausC (Klaus Crusius)


huge = floatmax(Float64) * (Double64(2)/3)
tiny = inv(huge)
large = cbrt(cbrt(cbrt(huged64)))
small = inv(large)

hugef = HI(huge)
tinyf = HI(tiny)
largef = HI(large)
smallf = HI(small)

@testset "corner arithmetic" begin
    @test isapprox(DoubleFloats.add2(hugef, tinyf), hugef + tinyf)
    @test isapprox(DoubleFloats.add2(tinyf, hugef), tinyf + hugef)
    @test isapprox(DoubleFloats.add2(hugef, hugef), hugef + hugef)
    @test isapprox(DoubleFloats.add2(tinyf, tinyf), tinyf + tiny)

    @test isapprox(DoubleFloats.sub2(hugef, tinyf), hugef - tinyf)
    @test isapprox(DoubleFloats.sub2(tinyf, hugef), tinyf - hugef)
    @test isapprox(DoubleFloats.sub2(hugef, hugef), hugef - hugef)
    @test isapprox(DoubleFloats.sub2(tinyf, tinyf), tinyf - tiny)

    @test isapprox(DoubleFloats.mul2(hugef, tinyf), hugef * tinyf)
    @test isapprox(DoubleFloats.mul2(tinyf, hugef), tinyf * hugef)
    @test isapprox(DoubleFloats.mul2(hugef, hugef), hugef * hugef)
    @test isapprox(DoubleFloats.mul2(tinyf, tinyf), tinyf * tinyf)

    @test isapprox(DoubleFloats.div2(hugef, tinyf), hugef / tinyf)
    @test isapprox(DoubleFloats.div2(tinyf, hugef), tinyf / hugef)
    @test isapprox(DoubleFloats.div2(hugef, hugef), hugef / hugef)
    @test isapprox(DoubleFloats.div2(tinyf, tinyf), tinyf / tinyf)
end
