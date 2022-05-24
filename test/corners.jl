# testing corner cases brought to light by KlausC (Klaus Crusius)


huge = floatmax(Float64) * (Double64(2)/3)
tiny = inv(huged64)
large = cbrt(cbrt(cbrt(huged64)))
small = inv(larged64)

hugef = HI(huge)
tinyf = HI(tiny)
largef = HI(large)
smallf = HI(small)

add2 = DoubleFloats.add2
sub2 = DoubleFloats.sub2
mul2 = DoubleFloats.mul2
div2 = DoubleFloats.div2

@testset "corner arithmetic" begin
    @test isapprox(add2(hugef, tinyf), hugef + tinyf)
    @test isapprox(add2(tinyf, hugef), tinyf + hugef)
    @test isapprox(add2(hugef, hugef), hugef + hugef)
    @test isapprox(add2(tinyf, tinyf), tinyf + tiny)

    @test isapprox(sub2(hugef, tinyf), hugef - tinyf)
    @test isapprox(sub2(tinyf, hugef), tinyf - hugef)
    @test isapprox(sub2(hugef, hugef), hugef - hugef)
    @test isapprox(sub2(tinyf, tinyf), tinyf - tiny)

    @test isapprox(mul2(hugef, tinyf), hugef * tinyf)
    @test isapprox(mul2(tinyf, hugef), tinyf * hugef)
    @test isapprox(mul2(hugef, hugef), hugef * hugef)
    @test isapprox(mul2(tinyf, tinyf), tinyf * tinyf)

    @test isapprox(div2(hugef, tinyf), hugef / tinyf)
    @test isapprox(div2(tinyf, hugef), tinyf / hugef)
    @test isapprox(div2(hugef, hugef), hugef / hugef)
    @test isapprox(div2(tinyf, tinyf), tinyf / tinyf)
end
