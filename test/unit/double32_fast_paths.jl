module Double32FastPathTests

using DoubleFloats, Random, Test
using DoubleFloats: simdmap!

const DF = DoubleFloats

const CASES = (
    (exp, (-64.0f0, 80.0f0)),
    (exp2, (-96.0f0, 112.0f0)),
    (expm1, (Float32(0x1p-40), 0.5f0)),
    (log, (0.125f0, 0.875f0), (1.125f0, 8.0f0)),
    (log2, (0.125f0, 0.875f0), (1.125f0, 8.0f0)),
    (log1p, (Float32(0x1p-40), 0.0625f0)),
    (atan, (Float32(0x1p-40), 1.0f0)),
    (tan, (Float32(0x1p-40), 0.5f0)),
    (sinh, (Float32(0x1p-40), 1.0f0)),
    (cosh, (Float32(0x1p-40), 1.0f0)),
    (tanh, (Float32(0x1p-40), 1.0f0)),
)

function within(f, x, actual, units)
    exact = f(BigFloat(x))
    return abs(BigFloat(actual) - exact) <= units * abs(exact)
end

@testset "Double32 elementary fast paths" begin
    rng = MersenneTwister(0x32e1)
    setprecision(BigFloat, 512) do
        unit = BigFloat(eps(Double32))
        for (f, ranges...) in CASES, (a, b) in ranges
            # Keep the first four blocks entirely eligible for each native
            # kernel. Include sparse two-word inputs in the dense workload.
            signed_range = !(f in (exp, exp2, log, log2))
            x = map(1:128) do i
                h = (signed_range && iseven(i) ? -1 : 1) * (a + (b - a) * rand(rng, Float32))
                l = iszero(i % 7) ? copysign(Float32(0x1p-110), h) : (rand(rng, Float32) - 0.5f0) * eps(h)
                Double32(h, l)
            end
            signs = signed_range ? (-1, 1) : (1,)
            for k in (a, b), h in (prevfloat(k), k, nextfloat(k)), s in signs
                for l in (-eps(h) / 2, 0.0f0, eps(h) / 2, Float32(0x1p-85))
                    push!(x, Double32(s * h, l))
                end
            end
            y = similar(x)
            @test simdmap!(f, y, x) === y
            @test all(within(f, t, f(t), 1.25 * unit) for t in x)
            @test all(within(f, t, r, 2.2 * unit) for (t, r) in zip(x, y))
            if f === log1p
                @test all(within(f, t, r, 1.0 * unit) for (t, r) in zip(x, y))
            end
        end

        # These low words cannot be combined exactly in Float64. At one
        # the entire logarithm is determined by the discarded component.
        for lo in (-Float32(0x1p-60), Float32(0x1p-60))
            x = Double32(1.0f0, lo)
            @test DF._double32_exact(exp, HILO(x)...) === nothing
            for f in (log, log2)
                @test within(f, x, f(x), 0.25 * unit)
            end
        end
        for f in (expm1, log1p, atan, tan, sinh, tanh)
            @test signbit(HI(f(Double32(-0.0f0))))
        end
        @test isinf(exp(Double32(90)))
        @test iszero(exp2(Double32(-151)))
        @test_throws DomainError log1p(Double32(-2))
        @test_throws DomainError tan(Double32(Inf))

        # Exercise both sides of each atan anchor choice and each
        # log2 mantissa table entry, including a spaced low word.
        for (f, heads) in
            ((atan, (Float32(2j + 1) / 32 for j in 0:15)), (log2, (2.0f0 + Float32(j) / 16 for j in 0:31)))
            x = [
                Double32(h, l) for center in heads for h in (prevfloat(center), center, nextfloat(center)) for
                l in (-eps(h) / 2, Float32(0x1p-85), eps(h) / 2)
            ]
            y = simdmap!(f, similar(x), x)
            @test all(within(f, t, r, 2.2 * unit) for (t, r) in zip(x, y))
        end

        powers = repeat(Double32.([0.125, 0.25, 0.5, 2, 4, 8]), 16)
        @test simdmap!(log2, similar(powers), powers) == log2.(powers)

        x = fill(Double32(1.25f0, Float32(0x1p-31)), 96)
        x[40] = Double32(-1)
        y = fill(Double32(-99), length(x))
        @test_throws DomainError simdmap!(log2, y, x)
        @test all(within(log2, x[i], y[i], 2.2 * unit) for i in 1:32)
        @test all(isequal(HILO(y[i]), HILO(log2(x[i]))) for i in 33:39)
        @test all(==(Double32(-99)), y[40:end])

        for n in (63, 64, 65, 4099)
            x = fill(Double32(0.3125f0, Float32(0x1p-65)), n)
            r = tanh.(x)
            y = simdmap!(tanh, similar(x), x; threaded = true)
            @test all(within(tanh, t, v, 2.2 * unit) for (t, v) in zip(x, y))
            @test simdmap!(tanh, x, x) === x
            @test all(isequal.(HILO.(x), HILO.(r)))
        end
    end
end

end
