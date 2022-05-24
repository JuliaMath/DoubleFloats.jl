# testing corner cases brought to light by KlausC (Klaus Crusius)

posinfinity = Double64(Inf)
neginfinity = -posinfinity
poszero = Double64(0.0)
negzero = -poszero
postwo = Double64(2)
negtwo = -postwo

posinfinityf = HI(posinfinity)
neginfinityf = HI(neginfinity)
poszerof = HI(poszero)
negzerof = HI(negzero)
postwof = HI(postwo)
negtwof = HI(negtwo)

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

@testset "division corners" begin
    @test isapprox(posinfinity / neginfinity, posinfinityf / neginfinityf)
    @test isapprox(posinfinity / poszero, posinfinityf / poszerof)
    @test isapprox(posinfinity / negzero, posinfinityf / negzerof)
    @test isapprox(poszero / posinfinity, poszerof / posinfinityf)
    @test isapprox(negzero / posinfinity, negzerof / posinfinityf)
    @test isapprox(poszero / neginfinity, poszerof / neginfinityf)
    @test isapprox(negzero / neginfinity, negzerof / neginfinityf)
    @test isapprox(neginfinity / negzero, neginfinityf / negzerof)

    @test isapprox(posinfinity / postwo, posinfinityf / postwof)
    @test isapprox(posinfinity / negtwo, posinfinityf / negtwof)
    @test isapprox(postwo / posinfinity, postwof / posinfinityf)
    @test isapprox(negtwo / posinfinity, negtwof / posinfinityf)
    @test isapprox(postwo / neginfinity, postwof / neginfinityf)
    @test isapprox(negtwo / neginfinity, negtwof / neginfinityf)
    @test isapprox(neginfinity / negtwo, neginfinityf / negtwof)

    @test isapprox(postwo / poszero, postwof / poszerof)
    @test isapprox(postwo / negzero, postwof / negzerof)
    @test isapprox(poszero / postwo, poszerof / postwof)
    @test isapprox(negzero / postwo, negzerof / postwof)
    @test isapprox(poszero / negtwo, poszerof / negtwof)
    @test isapprox(negzero / negtwo, negzerof / negtwof)
    @test isapprox(negtwo / negzero, negtwof / negzerof)
end
