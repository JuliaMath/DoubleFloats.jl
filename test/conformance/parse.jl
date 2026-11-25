# Text in: tryparse, parse, string constructors, macros.

@testset "parsing" begin
    for T in CONFORMANCE_TYPES
        name = typename(T)
        F = wordof(T)

        property("parse/tryparse of a number/" * name) do
            tryparse(T, "0.5") == T(F(0.5))
        end
        property("parse/tryparse of bad text is nothing/" * name) do
            tryparse(T, "abc") === nothing && tryparse(T, "") === nothing && tryparse(T, "1.2.3") === nothing
        end
        property("parse/parse of bad text throws ArgumentError/" * name) do
            throws(() -> parse(T, "abc"), ArgumentError)
        end
        property("parse/string constructor of bad text throws ArgumentError/" * name) do
            throws(() -> T("abc"), ArgumentError)
        end
        property("parse/string constructor equals parse/" * name) do
            T("0.1") === parse(T, "0.1")
        end
        property("parse/parse is correctly rounded/" * name) do
            x = parse(T, "0.1")
            HI(x) == F(0.1) &&
                HI(x) + LO(x) == HI(x) &&
                abs(exact(x) - 1 // 10) <= Rational{BigInt}(eps(HI(x))) * eps(F)
        end
        property("parse/special values/" * name) do
            isnan(parse(T, "NaN")) && parse(T, "Inf") == Inf && parse(T, "-Inf") == -Inf
        end
        property("parse/a failed parse leaves BigFloat precision alone/" * name) do
            before = precision(BigFloat)
            try
                parse(T, "abc")
            catch
            end
            try
                tryparse(T, "abc")
            catch
            end
            precision(BigFloat) == before
        end
        property("parse/a successful parse leaves BigFloat precision alone/" * name) do
            before = precision(BigFloat)
            parse(T, "0.1")
            precision(BigFloat) == before
        end
        property("parse/digits beyond the head are kept/" * name) do
            # 0.1 as a Float64, written out, is not the pair nearest 1/10.
            F === Float16 || parse(T, "0.1000000000000000055511151231257827") != parse(T, "0.1")
        end
        property("parse/a far low word is kept/" * name) do
            # 1 + 1e-61 is a pair: the low word may lie far below the head.
            F !== Float64 || (x = parse(T, "1." * "0"^60 * "1"); HI(x) == 1 && LO(x) == 1.0e-61)
        end
        property("parse/hexadecimal and exponent forms/" * name) do
            parse(T, "1e2") == 100 && parse(T, "1.5e-1") == T(F(0.15)) + (parse(T, "0.15") - T(F(0.15)))
        end
    end
    property("parse/string macros") do
        df64"0.5" === Double64(0.5) && df32"0.5" === Double32(0.5f0) && df16"0.5" === Double16(Float16(0.5))
    end
end
