@testset "Double64 elementary fast paths" begin
    setprecision(BigFloat, 1536) do
        unit = BigFloat(eps(Double64))
        function check(f, x)
            expected = f(BigFloat(x))
            actual = BigFloat(f(x))
            step = BigFloat(nextfloat(0.0))
            if abs(expected) * unit < step
                @test actual == round(expected / step) * step
            else
                @test abs(actual - expected) <= BigFloat(2.2) * unit * abs(expected)
            end
        end
        for (f, a, b) in (
            (atan, -1.0, 1.0),
            (tan, -0.5, 0.5),
            (sinh, -1.0, 1.0),
            (cosh, -1.0, 1.0),
            (tanh, -1.0, 1.0),
            (exp, -670.0, 700.0),
            (exp2, -966.0, 1023.0),
            (expm1, -1.0, 1.0),
            (log, 0.9375, 1.0625),
            (log2, 0.9375, 1.0625),
            (log1p, -0.125, 0.125),
        )
            for h in range(a, b; length = 193), t in (-0.5, 0.5)
                check(f, Double64(h, t * eps(h)))
            end
        end

        for j in 0:127
            # Finer table entry switches, with both sides exercised in each
            # exponent on either side of one.
            abscissa = (2j + 1) / 256
            for (f, x) in (
                (exp, Double64(BigFloat(abscissa) * log(big"2.0"))),
                (exp2, Double64(abscissa)),
                (log, Double64(1 + j / 128)),
                (log, Double64((1 + j / 128) / 2)),
                (log2, Double64(1 + j / 128)),
            )
                h, l = HILO(x)
                for tail in (prevfloat(l), l, nextfloat(l))
                    check(f, Double64(h, tail))
                end
            end
        end
        for f in (sinh, cosh, tanh, tan, expm1, atan)
            bound = f === tan ? 0.5 : 1.0
            for sign in (-1.0, 1.0), h in (prevfloat(bound), bound, nextfloat(bound)), t in (-0.5, 0.5)
                check(f, Double64(sign * h, t * eps(h)))
            end
        end

        # The spaced low limb is lost in conversion to Float128. Exercise
        # both signs and the usual circle and general fallbacks.
        for head in (Float64(pi) / 2, Float64(pi), 3Float64(pi) / 2, 100.0), lo in (-0x1p-120, 0x1p-120)
            check(tan, Double64(head, lo))
        end
        check(tan, Double64(pi))
    end

    q = nextfloat(0.0)
    for lo in (-q, q)
        @test HILO(log(Double64(1.0, lo))) == (lo, 0.0)
        @test HILO(log2(Double64(1.0, lo))) == (lo, 0.0)
        for f in (expm1, log1p, atan, sinh, tanh, tan)
            @test HILO(f(Double64(lo))) == (lo, 0.0)
        end
    end
    for f in (expm1, log1p, atan, sinh, tanh, tan)
        @test signbit(HI(f(Double64(-0.0))))
    end
end
