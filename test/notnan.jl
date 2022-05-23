# tests that NaN is not returned incorrectly

hugef64 = floatmax(Float64) * (2/3)
tinyf64 = inv(hugef64)
huged64 = floatmax(Float64) * (Double64(2)/3)
tinyd64 = inv(huged64)

zerof64 = 0.0
zerod64 = zero(Double64)
onef64 = 1.0
oned64 = one(Double64)
inff64 = Inf
infd64 = Double64(Inf)


@testset "not nan" begin
    @test isapprox(huged64 + huged64, hugef64 + hugef64)
    @test isapprox(huged64 + tinyd64, hugef64 + tinyf64)
    @test isapprox(tinyd64 + huged64, tinyf64 + hugef64)
    @test isapprox(tinyd64 + tinyd64, tinyf64 + tinyf64)

    @test isapprox(huged64 - huged64, hugef64 - hugef64)
    @test isapprox(huged64 - tinyd64, hugef64 - tinyf64)
    @test isapprox(tinyd64 - huged64, tinyf64 - hugef64)
    @test isapprox(tinyd64 - tinyd64, tinyf64 - tinyf64)

    @test isapprox(huged64 * huged64, hugef64 * hugef64)
    @test isapprox(huged64 * tinyd64, hugef64 * tinyf64)
    @test isapprox(tinyd64 * huged64, tinyf64 * hugef64)
    @test isapprox(tinyd64 * tinyd64, tinyf64 * tinyf64)

    @test isapprox(huged64 / huged64, hugef64 / hugef64)
    @test isapprox(huged64 / tinyd64, hugef64 / tinyf64)
    @test isapprox(tinyd64 / huged64, tinyf64 / hugef64)
    @test isapprox(tinyd64 / tinyd64, tinyf64 / tinyf64)

    @test isapprox(huged64 + hugef64, hugef64 + huged64)
    @test isapprox(huged64 + tinyf64, hugef64 + tinyd64)
    @test isapprox(tinyd64 + hugef64, tinyf64 + huged64)
    @test isapprox(tinyd64 + tinyf64, tinyf64 + tinyd64)

    @test isapprox(huged64 - hugef64, hugef64 - huged64)
    @test isapprox(huged64 - tinyf64, hugef64 - tinyd64)
    @test isapprox(tinyd64 - hugef64, tinyf64 - huged64)
    @test isapprox(tinyd64 - tinyf64, tinyf64 - tinyd64)

    @test isapprox(huged64 * hugef64, hugef64 * huged64)
    @test isapprox(huged64 * tinyf64, hugef64 * tinyd64)
    @test isapprox(tinyd64 * hugef64, tinyf64 * huged64)
    @test isapprox(tinyd64 * tinyf64, tinyf64 * tinyd64)

    @test isapprox(huged64 / hugef64, hugef64 / huged64)
    @test isapprox(huged64 / tinyf64, hugef64 / tinyd64)
    @test isapprox(tinyd64 / hugef64, tinyf64 / huged64)
    @test isapprox(tinyd64 / tinyf64, tinyf64 / tinyd64)

end

@testset "with Inf, zero" begin
    @test isapprox(infd64 + zerod64, inff64 + zerof64)
    @test isapprox(infd64 - zerod64, inff64 - zerof64)
    @test isapprox(zerod64 - inff64, zerof64 - inff64)
    @test isapprox(infd64 * zerod64, inff64 * zerof64)
    @test isapprox(infd64 / zerod64, inff64 / zerof64)
    @test isapprox(zerod64 / infd64, zerof64 / inff64)
    
    @test isapprox(infd64 + zerof64, inff64 + zerod64)
    @test isapprox(infd64 - zerof64, inff64 - zerod64)
    @test isapprox(zerod64 - inff64, zerof64 - infd64)
    @test isapprox(infd64 * zerof64, inff64 * zerod64)
    @test isapprox(infd64 / zerof64, inff64 / zerod64)
    @test isapprox(zerod64 / infd64, zerof64 / infd64)
end