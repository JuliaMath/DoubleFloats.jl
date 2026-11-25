# Conversion out: exact, correctly rounded, or an error.

@testset "conversion" begin
    for T in CONFORMANCE_TYPES
        name = typename(T)
        F = wordof(T)

        property("convert/Int64 of an integer value/" * name) do
            Int64(T(3)) === Int64(3) && Int64(T(-4)) === Int64(-4)
        end
        property("convert/Int64 of a fraction throws InexactError/" * name) do
            throws(() -> Int64(T(F(2.5))), InexactError)
        end
        property("convert/convert(Int, x) of a fraction throws InexactError/" * name) do
            throws(() -> convert(Int, T(F(2.5))), InexactError)
        end
        property("convert/Int64 out of range throws InexactError/" * name) do
            F === Float16 || throws(() -> Int64(T(F(2))^70), InexactError)
        end
        property("convert/Int64 of NaN and Inf throws InexactError/" * name) do
            throws(() -> Int64(T(F(NaN))), InexactError) && throws(() -> Int64(T(F(Inf))), InexactError)
        end
        property("convert/typemax(Int64) round trip/" * name) do
            F !== Float64 || Int64(T(typemax(Int64))) === typemax(Int64)
        end
        property("convert/trunc, floor, ceil to Int/" * name) do
            x = T(F(2.5))
            trunc(Int, x) == 2 && floor(Int, x) == 2 && ceil(Int, x) == 3
        end
        property("convert/round to Int rounds ties to even/" * name) do
            round(Int, T(F(2.5))) == 2 && round(Int, T(F(3.5))) == 4 && round(Int, T(F(-2.5))) == -2
        end
        property("convert/round rounds ties to even/" * name) do
            round(T(F(2.5))) == 2 && round(T(F(3.5))) == 4 && round(T(F(0.5))) == 0
        end
        property("convert/the word type, correctly rounded/" * name) do
            x = words(T, 1, eps(F) / 4)
            F(x) === F(1) && F(words(T, 1, -eps(F) / 8)) === F(1)
        end
        property("convert/Float64 of a pair/" * name) do
            Float64(T(F(0.5))) === 0.5
        end
        property("convert/BigInt of an integer value/" * name) do
            BigInt(T(12)) == 12
        end
        property("convert/rationalize finds 1//3/" * name) do
            rationalize(T(1) / 3) == 1 // 3
        end
        property("convert/rationalize honours tol/" * name) do
            rationalize(T(F(0.333)); tol = 0.01) == 1 // 3
        end
        property("convert/Bool/" * name) do
            Bool(T(1)) === true && Bool(T(0)) === false && throws(() -> Bool(T(2)), InexactError)
        end
        property("convert/widen/" * name) do
            widen(T) === (F === Float64 ? BigFloat : F === Float32 ? Double64 : Double32)
        end
    end
end
