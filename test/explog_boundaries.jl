@testset "Log mantissa scaling" begin
    setprecision(BigFloat, 512) do
        for (D, T, tiny) in ((Double64, Float64, 0x1p-915),
                             (Double32, Float32, Float32(0x1p-77)))
            q = nextfloat(zero(T))
            for (hi, lo) in ((q, zero(T)), (T(4), floatmin(T)),
                             (T(2)^100, floatmin(T)), (T(2), floatmin(T)),
                             (T(2)^100, q), (T(1.5), eps(T)/2),
                             (floatmin(T)*T(2)^10, q),
                             (prevfloat(tiny), prevfloat(floatmin(T))),
                             (tiny, prevfloat(floatmin(T))))
                for sign in (-one(T), one(T))
                    x = D(hi, sign * lo)
                    reference = BigFloat(HI(x)) + BigFloat(LO(x))
                    tolerance = BigFloat(8) * eps(T)^2
                    for op in (log2, log, log10)
                        actual = BigFloat(op(x))
                        expected = op(reference)
                        @test isfinite(actual)
                        @test abs(actual - expected) <= tolerance * abs(expected)
                    end
                    native_hi, native_lo = DoubleFloats._unsafe_log2(HILO(x))
                    @test abs(BigFloat(native_hi) + BigFloat(native_lo) - log2(reference)) <=
                          tolerance * abs(log2(reference))
                end
            end
        end
    end
end

@testset "Exponential underflow rounding" begin
    setprecision(BigFloat, 1536) do
        for (D, T, zero_midpoint) in ((Double64, Float64, -1075.0),
                                      (Double32, Float32, -150.0f0))
            q = nextfloat(zero(T))
            for lo in (-q, -eps(T)^2, zero(T), q, eps(T)^2)
                @test HILO(exp2(D(zero_midpoint, lo))) ===
                      (lo > 0 ? q : zero(T), zero(T))
            end
            @test HILO(exp2(D(zero_midpoint + one(T)))) === (q, zero(T))
            @test HILO(exp2(D(exponent(floatmin(T))))) === (floatmin(T), zero(T))

            # Use both sides of mathematically known midpoints, including the
            # transition from the largest subnormal to the minimum normal.
            last_subnormal = (Int64(1) << Base.significand_bits(T)) - 1
            for (op, inverse) in ((exp2, log2), (exp, log), (exp10, log10))
                for n in (0, 1, 2, 19, last_subnormal)
                    midpoint = inverse((BigFloat(n) + BigFloat(0.5)) * BigFloat(q))
                    hi = T(midpoint)
                    lo = T(midpoint - BigFloat(hi))
                    for nudge in (prevfloat, nextfloat)
                        adjacent = nudge(lo)
                        exact_input = BigFloat(hi) + BigFloat(adjacent)
                        expected = T(exact_input > midpoint ? n+1 : n) * q
                        actual = op(D(hi, adjacent))
                        @test HILO(actual) === (expected, zero(T))
                    end
                end
                @test op(D(-T(10_000))) == zero(D)
                @test op(D(-zero(T))) == one(D)
                @test op(D(zero(T))) == one(D)
                @test op(D(-Inf)) == zero(D)
                @test op(D(Inf)) == D(Inf)
                @test isnan(op(D(NaN)))
            end
        end
        precision_before = precision(BigFloat)
        rounding_before = rounding(BigFloat)
        q = nextfloat(0.0)
        @test DoubleFloats._exp_subnormal_refine(exp2, (-1074.5, 0.0)) == q
        @test DoubleFloats._exp_subnormal_refine(exp2, (-1074.0, 0.0)) == q
        # The 128-bit input sum is inexact because the limbs are far apart.
        @test DoubleFloats._exp_subnormal_refine(exp2, (-1074.0, q)) == q
        @test (precision(BigFloat), rounding(BigFloat)) == (precision_before, rounding_before)
    end
end
