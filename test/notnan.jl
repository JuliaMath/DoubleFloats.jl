# tests that NaN is not returned incorrectly

huged64 = floatmax(Float64) * (Double64(2)/3)
tinyd64 = inv(huged64)
hugef64 = HI(huged64)
tinyf64 = HI(tinyd64)

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

    @test isapprox(HI(huged64) - hugef64, hugef64 - HI(huged64))
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

@testset "not NaN and NaN" begin

    @testset "unary operators $op($T)" for op in (log, exp, sqrt, cbrt, square, cube, log2, log10, exp2, exp10),
        T in (Double64, Double32, Double16)
        
        d = floatmax(T)
        if op ∈ (exp, square, cube, exp2, exp10)
            @test isinf(op(d))
        else
            @test isfinite(op(d))
        end
        @test isinf(T(2.1) ^ d)
        @test isinf(3 ^ d)
        @test iszero(0.999 ^ d)
        @test isinf(10 ^ T(500.5))

        d = -floatmax(T)
        op ∉ (sqrt, log, log2, log10) && @test !isnan(op(d))
        d = T(NaN)
        @test isnan(op(d))
    end

    @testset "binary operators $T $op $T" for op in (+, -, *, /), T in (Double64, Double32, Double16)

        d1, d2 = floatmax(T), floatmax(T)
        @test !isnan(op(d1, d2))
        d1, d2 = floatmax(T), -floatmax(T)
        @test !isnan(op(d1, d2))
        d1, d2 = T(Inf), floatmax(T)
        @test !isnan(op(d1, d2))
        d1, d2 = T(Inf), T(Inf)
        @test isnan(op(d1, d2)) == (op ∈ (-, /))
        d1, d2 = zero(T), T(NaN)
        @test isnan(op(d1, d2))
    end

end