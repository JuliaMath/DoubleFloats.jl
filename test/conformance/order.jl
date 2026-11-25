# P-ORD: ==, <, <=, isequal, isless, and hash agree with exact values.

@testset "order" begin
    for T in CONFORMANCE_TYPES
        name = typename(T)
        F = wordof(T)
        xs = ordervalues(T)
        pairs = [(a, b) for a in xs for b in xs]

        property("order/==/" * name) do
            all(((a, b),) -> (a == b) === refeq(a, b), pairs)
        end
        property("order/!=/" * name) do
            all(((a, b),) -> (a != b) === !refeq(a, b), pairs)
        end
        property("order/</" * name) do
            all(((a, b),) -> (a < b) === reflt(a, b), pairs)
        end
        property("order/<=/" * name) do
            all(((a, b),) -> (a <= b) === (reflt(a, b) || refeq(a, b)), pairs)
        end
        property("order/isequal/" * name) do
            all(((a, b),) -> isequal(a, b) === refisequal(a, b), pairs)
        end
        property("order/isless/" * name) do
            all(((a, b),) -> isless(a, b) === refisless(a, b), pairs)
        end
        property("order/NaN is not equal to itself/" * name) do
            T(F(NaN)) != T(F(NaN))
        end
        property("order/sort/" * name) do
            v = T[1, F(NaN), 0, -1, F(Inf), F(-0.0), F(-Inf)]
            s = sort(v)
            issorted(s; lt = isless) &&
                isnan(last(s)) &&
                HI(first(s)) == F(-Inf) &&
                signbit(HI(s[3])) &&
                !signbit(HI(s[4]))
        end
        property("order/minimum and maximum/" * name) do
            v = T[3, 1, 2]
            minimum(v) == 1 && maximum(v) == 3
        end
        property("order/hash follows isequal/" * name) do
            all(((a, b),) -> !isequal(a, b) || hash(a) == hash(b), pairs)
        end

        # Against other number types, on exact values.
        others = Any[
            0.0,
            -0.0,
            1.0,
            -1.0,
            0.5,
            1 / 3,
            Inf,
            -Inf,
            NaN,
            1.0f0,
            Float32(1) / 3,
            0,
            1,
            -1,
            2,
            typemax(Int64),
            big(1),
            big(1) / 3,
            big(1.0) + big(2.0) ^ -100,
            1 // 3,
            1 // 2,
            -1 // 1,
            big(1) // big(3),
        ]
        mixed = [(a, y) for a in xs for y in others]
        property("order/mixed ==/" * name) do
            all(((a, y),) -> (a == y) === refeq(a, y) && (y == a) === refeq(y, a), mixed)
        end
        property("order/mixed </" * name) do
            all(((a, y),) -> (a < y) === reflt(a, y) && (y < a) === reflt(y, a), mixed)
        end
        property("order/mixed <=/" * name) do
            all(((a, y),) -> (a <= y) === (reflt(a, y) || refeq(a, y)), mixed)
        end
        property("order/a third is not 1//3/" * name) do
            T(1) / 3 != 1 // 3
        end
        property("order/hash equals that of an equal Float64/" * name) do
            all(y -> hash(T(y)) == hash(y), F[0, 1, -1, 0.5, 3, F(1) / 3, F(Inf), F(-Inf)])
        end
        property("order/hash equals that of an equal BigFloat/" * name) do
            x = words(T, 1, eps(F) / 4)
            b = BigFloat(HI(x); precision = 256) + BigFloat(LO(x); precision = 256)
            x == b && hash(x) == hash(b)
        end
        property("order/Dict lookup by an equal Float64/" * name) do
            d = Dict(F(0.5) => 1)
            haskey(d, T(F(0.5))) && get(Dict(T(F(0.5)) => 2), F(0.5), 0) == 2
        end
        property("order/Set merges equal values of two types/" * name) do
            length(Set(Any[F(0.5), T(F(0.5))])) == 1
        end
        property("order/unique/" * name) do
            length(unique(T[1, 1, 2, F(NaN), F(NaN)])) == 3
        end
    end
end
