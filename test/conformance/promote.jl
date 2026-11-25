# Promotion: the result type contains both operand types, to rounding.

@testset "promotion" begin
    table = [
        (Double64, Float64, Double64),
        (Double64, Float32, Double64),
        (Double64, Float16, Double64),
        (Double64, Int64, Double64),
        (Double64, Rational{Int}, Double64),
        (Double64, BigFloat, BigFloat),
        (Double64, BigInt, Double64),
        (Double64, Bool, Double64),
        (Double32, Float32, Double32),
        (Double32, Float16, Double32),
        (Double32, Float64, Double64),
        (Double32, Int64, Double32),
        (Double32, BigFloat, BigFloat),
        (Double16, Float16, Double16),
        (Double16, Float32, Double32),
        (Double16, Float64, Double64),
        (Double16, Int64, Double16),
        (Double16, BigFloat, BigFloat),
        (Double64, Double32, Double64),
        (Double64, Double16, Double64),
        (Double32, Double16, Double32),
    ]
    for (A, B, R) in table
        property(string("promote/", A, " with ", B, " gives ", R)) do
            promote_type(A, B) === R && promote_type(B, A) === R
        end
    end
    property("promote/Double64 with an Irrational") do
        typeof(Double64(1) + pi) === Double64 && typeof(pi * Double32(1)) === Double32
    end
    property("promote/Double64 with Float128 gives Float128") do
        promote_type(Double64, Quadmath.Float128) === Quadmath.Float128
    end
    property("promote/arithmetic follows the table") do
        typeof(Double32(1) + 1.0) === Double64 &&
            typeof(Double16(1) * 1.0f0) === Double32 &&
            typeof(Double64(1) + 1.0f0) === Double64
    end
    property("promote/complex") do
        typeof(ComplexDF64(1, 2) + 1.0) === ComplexDF64 && typeof(Double64(1) + (1.0 + 2.0im)) === ComplexDF64
    end
end
