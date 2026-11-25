# The value: one invariant, exact construction, exact views.

@testset "construction" begin
    for T in CONFORMANCE_TYPES
        name = typename(T)
        F = wordof(T)
        normalized(x) = !isfinite(HI(x)) || HI(x) + LO(x) == HI(x)

        property("construct/pair constructor normalizes/" * name) do
            x = T(F(1), F(1))
            normalized(x) && x == 2
        end
        property("construct/pair constructor keeps a normalized pair/" * name) do
            x = T(F(1), eps(F) / 4)
            HI(x) === F(1) && LO(x) === eps(F) / 4
        end
        property("construct/untyped pair constructor normalizes/" * name) do
            normalized(DoubleFloat(F(1), F(1)))
        end
        property("construct/non-finite pair has a zero low word/" * name) do
            x = T(F(Inf), F(Inf))
            isinf(x) && iszero(LO(x)) && isnan(T(F(Inf), F(-Inf)))
        end
        property("construct/isnormalized exists/" * name) do
            DoubleFloats.isnormalized(T(F(1), eps(F) / 4)) && DoubleFloats.isnormalized(T(F(Inf)))
        end
        property("construct/results are normalized/" * name) do
            xs = filter(x -> isfinite(HI(x)), ordervalues(T))
            all(normalized, [f(a, b) for f in (+, -, *) for a in xs for b in xs])
        end
        property("construct/from the word type/" * name) do
            x = T(F(1) / 3)
            HI(x) === F(1) / 3 && iszero(LO(x))
        end
        property("construct/from Float64 is exact where it fits/" * name) do
            F === Float16 || T(1 / 3) == (F === Float64 ? 1 / 3 : exact(T(1 / 3)) == exact(1 / 3) ? 1 / 3 : T(1 / 3))
        end
        property("construct/small integers are exact/" * name) do
            all(n -> exact(T(n)) == n, (-7, 0, 1, 255, 1000))
        end
        property("construct/integers wider than a word are exact/" * name) do
            n = Int64(2)^(precision(F) + 5) + 1
            F === Float16 ? exact(T(Int64(2)^15 + 1)) == 2^15 + 1 : exact(T(n)) == n
        end
        property("construct/typemax(Int64) is exact/" * name) do
            F !== Float64 || exact(T(typemax(Int64))) == typemax(Int64)
        end
        property("construct/2^62 + 1 is exact/" * name) do
            F !== Float64 || exact(T(2^62 + 1)) == big(2)^62 + 1
        end
        property("construct/from BigFloat is correctly rounded/" * name) do
            b = big(1) / 3
            x = T(b)
            normalized(x) &&
                HI(x) == F(b) &&
                abs(exact(x) - Rational{BigInt}(b)) <= Rational{BigInt}(eps(HI(x))) * eps(F)
        end
        property("construct/from Rational/" * name) do
            x = T(1 // 3)
            normalized(x) && HI(x) == F(1) / 3 && !iszero(LO(x))
        end
        property("construct/from an Irrational/" * name) do
            x = T(pi)
            normalized(x) && HI(x) == F(pi) && !iszero(LO(x))
        end
        property("construct/nested pair type cannot be named/" * name) do
            throws(() -> DoubleFloat{T}, TypeError)
        end
        property("construct/zero and one/" * name) do
            iszero(zero(T)) && isone(one(T)) && zero(T) + one(T) == 1
        end
        property("construct/BigFloat of a pair is exact/" * name) do
            x = words(T, 1, eps(F) / 4)
            Rational{BigInt}(BigFloat(x)) == exact(x)
        end
        property("construct/Rational of a pair is exact/" * name) do
            x = words(T, F(1) / 3, eps(F(1) / 3) / 4)
            Rational(x) == exact(x)
        end
        property("construct/decompose is exact/" * name) do
            x = words(T, F(1) / 3, eps(F(1) / 3) / 4)
            n, p, s = Base.decompose(x)
            s * n * Rational{BigInt}(2)^p == exact(x)
        end
        property("construct/words round trip through reinterpret/" * name) do
            v = T[words(T, 1, eps(F) / 4), words(T, 2, 0)]
            w = reinterpret(F, v)
            length(w) == 4 && collect(reinterpret(T, collect(w))) == v
        end
    end
end
