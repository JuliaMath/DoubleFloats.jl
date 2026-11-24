module SIMDElementaryTests

using DoubleFloats, Random, Test
using DoubleFloats: simdmap!
const DF = DoubleFloats

limbs(x::DoubleFloat) = HILO(x)
limbs(x::Complex) = (limbs(real(x)), limbs(imag(x)))
limbs(x::Tuple) = map(limbs, x)
limbs(x) = x

function same_limbs(x, y)
    typeof(x) === typeof(y) && isequal(limbs(x), limbs(y))
end

function compare_batch(f::F, args...; threaded=false) where {F}
    broadcast_args = map(x -> x isa Number ? Ref(x) : x, args)
    reference = f.(broadcast_args...)
    dest = similar(reference)
    @test simdmap!(f, dest, args...; threaded) === dest
    @test all(same_limbs.(dest, reference))
    return dest
end

function bounded(lower, upper)
    rng = MersenneTwister(0x5eed)
    left, right = nextfloat(lower), prevfloat(upper)
    result = map(rand(rng, 131)) do t
        h = left + (right - left) * t
        Double64(h, (rand(rng) - 0.5) * eps(h))
    end
    # The first block stays eligible and exercises the window endpoints.
    for (i, h) in enumerate((lower, left, right, upper))
        result[2i - 1] = Double64(h, -0.5 * eps(h))
        result[2i] = Double64(h, 0.5 * eps(h))
    end
    # The second block mixes nearby rejected heads and unusual low limbs.
    for (i, h) in enumerate((prevfloat(lower), nextfloat(upper)))
        result[64 + 2i - 1] = Double64(h, -0.5 * eps(h))
        result[64 + 2i] = Double64(h, 0.5 * eps(h))
    end
    result[71] = Double64((left + right) / 2, 1e-12)
    result[72] = Double64((left + right) / 2, -1e-12)
    return result
end

function batch_allocations(f::F, dest, x) where {F}
    simdmap!(f, dest, x)
    return @allocated simdmap!(f, dest, x)
end

function batch_allocations(f::F, dest, x, y) where {F}
    simdmap!(f, dest, x, y)
    return @allocated simdmap!(f, dest, x, y)
end

struct ShiftedVector{T} <: AbstractVector{T}
    storage::Vector{T}
end
Base.size(x::ShiftedVector) = size(x.storage)
Base.axes(x::ShiftedVector) = (0:(length(x.storage) - 1),)
Base.getindex(x::ShiftedVector, i::Int) = x.storage[i + 1]
Base.setindex!(x::ShiftedVector, v, i::Int) = (x.storage[i + 1] = v)

@testset "Elementary vector evaluation" begin
    @testset "Bounded real arithmetic" begin
        for f in (sin, cos, tan, cot, sincos, cis)
            compare_batch(f, bounded(0.005, 0.09))
        end
        negative = bounded(-0.09, -0.005)
        for f in (sin, cos, tan, sincos, cis)
            compare_batch(f, vcat(negative, fill(Double64(-0.0625, -0.0), 64)))
        end
        compare_batch(atan, bounded(0.005, 0.19))
        for f in (exp, exp2, exp10)
            x = vcat(bounded(-32.0, -0.001), bounded(0.001, 32.0))
            compare_batch(f, x)
        end
        compare_batch(exp2, bounded(-1021.0, -0.001))
        compare_batch(exp2, bounded(0.001, 1023.0))
        for f in (log, log2, log10)
            compare_batch(f, vcat(bounded(0.95, 1.05), bounded(1.1, 4.0)))
            compare_batch(f, bounded(nextfloat(0.9375), prevfloat(1.0625)))
            compare_batch(f, bounded(0x1p-915, 0.9375))
            compare_batch(f, bounded(1.0625, floatmax(Float64)))
        end
        compare_batch(log1p, bounded(0.005, 0.05))
        compare_batch(expm1, vcat(bounded(0.032, 0.06), bounded(0.5, 32.0), bounded(-32.0, -0.5)))
        x = bounded(0.5, 1.5)
        compare_batch(^, x, 5)
        compare_batch(x -> x^5, x)
        compare_batch(^, x, repeat([-2, 0, 5], 44)[1:length(x)])
        compare_batch(^, x, Double64(1.5))
        compare_batch(^, bounded(1.1, 1.5), bounded(0.2, 0.9))
        compare_batch(^, fill(Double64(-2), 65), fill(Double64(3), 65))
        for f in (sinh, cosh, tanh, csch, sech, coth)
            compare_batch(f, bounded(1.1, 5.0))
        end
        for (f, lower, upper) in ((asinh, 0.005, 0.045), (acosh, 1.00002, 1.001),
                (atanh, 0.005, 0.025), (acsch, 30.0, 50.0),
                (asech, 0.999, 0.99998), (acoth, 40.0, 100.0))
            compare_batch(f, bounded(lower, upper))
        end
    end

    @testset "Sparse repair and exceptional ordering" begin
        for f in (exp2, sin, cos, tan)
            x = fill(Double64(0.03125, -1e-20), 137)
            x[1] = Double64(-0.0)
            x[32] = Double64(70)
            x[65] = Double64(50)
            x[128] = Double64(-10)
            compare_batch(f, x)
        end
        x = fill(Double64(0.03125), 137)
        x[70] = Double64(1.25)
        x[95] = Double64(Inf)
        dest = fill(Double64(-1), length(x))
        @test_throws DomainError simdmap!(sin, dest, x)
        @test all(same_limbs.(dest[1:94], sin.(x[1:94])))
        @test all(==(-1), dest[95:end])
    end

    @testset "Wider converted exponentials" begin
        for (f, first_head, last_head) in ((exp, 0.001, 700.0), (exp10, 0.001, 300.0),
                                           (expm1, 0.5, 700.0))
            compare_batch(f, bounded(first_head, last_head))
            compare_batch(f, bounded(-last_head, -first_head))
            compare_batch(f, vcat(bounded(first_head, last_head),
                                  Double64[0, -0.0, NaN, Inf, -Inf, -800, 800]))
        end
        compare_batch(expm1, bounded(0x1p-5, prevfloat(0x1p-4)))
        compare_batch(expm1, bounded(-prevfloat(0x1p-4), -0x1p-5))
        setprecision(256) do
            for (f, factor, k) in ((exp, log(big(2.0)), 997), (exp10, log10(big(2.0)), 992))
                midpoint = Double64(k * factor + factor / 2)
                mids = Double64[Double64(HI(midpoint), l) for l in
                                (prevfloat(LO(midpoint)), LO(midpoint), nextfloat(LO(midpoint)))]
                compare_batch(f, repeat(vcat(mids, -mids), 16))
                for (x, y) in zip(mids, f.(mids))
                    exact = f(BigFloat(HI(x)) + BigFloat(LO(x)))
                    @test abs((BigFloat(HI(y)) + BigFloat(LO(y))) / exact - 1) < big(2.0)^(-98)
                end
            end
        end
    end

    @testset "Real vector magnitudes and reciprocals" begin
        x = bounded(0.25, 8.0)
        y = reverse(x)
        for f in (hypot, DF.normalize)
            for (a, b) in ((x, y), (-x, y), (x, -y), (-x, -y), (x, x))
                compare_batch(f, a, b)
            end
            a = repeat(Double64[Double64(2.0, 0.0), Double64(2.0, -0.0)], 40)
            b = reverse(a)
            compare_batch(f, a, b)
            compare_batch(f, a, reverse(b))
            special = Double64[-0.0, 0.0, Inf, -Inf, NaN, nextfloat(0.0), floatmax(Float64),
                               Double64(0.0, 1.0), Double64(1.0, Inf), Double64(1.0, NaN)]
            compare_batch(f, vcat(x, special), vcat(y, reverse(special)))
        end
        expected = hypot.(x, y)
        alias = copy(y)
        @test simdmap!(hypot, alias, x, alias) === alias
        @test all(same_limbs.(alias, expected))
        compare_batch(inv, bounded(0x1p-256, 0x1p256))
        compare_batch(inv, bounded(-0x1p256, -0x1p-256))
        reciprocals = Double64[0.0, -0.0, Inf, -Inf, NaN, nextfloat(0.0), floatmin(Float64),
                               floatmax(Float64), Double64(2.0, NaN)]
        compare_batch(inv, vcat(x, reciprocals))
        @test iszero(batch_allocations(hypot, similar(x), x, y))
        @test iszero(batch_allocations(DF.normalize, Vector{Tuple{Double64,Double64}}(undef, length(x)), x, y))
        @test iszero(batch_allocations(inv, similar(x), x))
    end

    @testset "Circular sectors, quadrants and poles" begin
        for f in (sincos, sin, cos, tan, cis)
            compare_batch(f, bounded(0.125, 0.18))
            angles = vcat(bounded(-6.25, -0.005), bounded(0.005, 6.25))
            shuffle!(MersenneTwister(0x521), angles)
            compare_batch(f, angles)
        end

        setprecision(256) do
            angles = Double64[]
            for k in 1:64
                anchor = Double64(k * big(pi) / 32)
                if HI(anchor) < 6.28125
                    for l in (prevfloat(LO(anchor)), LO(anchor), nextfloat(LO(anchor)))
                        angle = Double64(HI(anchor), l)
                        append!(angles, (angle, -angle))
                    end
                end
            end
            pairs = compare_batch(sincos, angles)
            sines, cosines = first.(pairs), last.(pairs)
            for (x, s, c) in zip(angles, sines, cosines)
                arg = BigFloat(HI(x)) + BigFloat(LO(x))
                @test abs(BigFloat(HI(s)) + BigFloat(LO(s)) - sin(arg)) < big(2.0)^(-96)
                @test abs(BigFloat(HI(c)) + BigFloat(LO(c)) - cos(arg)) < big(2.0)^(-96)
            end
            for f in (sin, cos, tan, cis)
                compare_batch(f, angles)
            end
        end
        guard = 0.11
        p = DF._trig_halfpi[1]
        for edge in (p - guard, p + guard, 6.28125, DF._trig_taylor_cutoff)
            angles = repeat(Double64[prevfloat(edge), edge, nextfloat(edge)], 24)
            for f in (tan, sin, cos, sincos, cis)
                compare_batch(f, angles)
            end
        end
        angles = fill(Double64(0.5), 128)
        angles[95] = Double64(Inf)
        dest = fill(Double64(-10), length(angles))
        @test_throws DomainError simdmap!(sin, dest, angles)
        @test all(same_limbs.(dest[1:94], sin(angles[1])))
        @test all(==(-10), dest[95:end])
    end

    @testset "Complex rectangles and branch cuts" begin
        small, smaller, large = bounded(0.005, 0.09), bounded(0.005, 0.045), bounded(1.1, 5.0)
        for f in (square, abs2, exp, sinh, cosh)
            compare_batch(f, complex.(large, small))
        end
        for f in (sin, cos)
            compare_batch(f, complex.(small, large))
        end
        for f in (tan, cot, DF.csc, DF.sec)
            compare_batch(f, complex.(smaller, large))
        end
        for f in (tanh, coth, csch, sech)
            compare_batch(f, complex.(large, smaller))
        end
        cuts = ComplexDF64[ComplexDF64(r, i) for r in (-2, -0.5, 0.5, 2)
                         for i in (0.0, -0.0, 1e-30, -1e-30)]
        for f in (sqrt, log, asin, acos, atan, acsc, asec, acot,
                  asinh, acosh, atanh, acsch, asech, acoth)
            compare_batch(f, cuts)
        end
    end

    @testset "Scalar special cases and independent references" begin
        for T in (Double64, Double32, Double16)
            x = T[-0.0, 0.0, 0.5, -0.5, 1, -1]
            for f in (sinpi, cospi, tanpi, sincospi, cispi, asin, acos, acot)
                compare_batch(f, x)
            end
            compare_batch(acsc, T[-2, -1, 1, 2])
            compare_batch(asec, T[-2, -1, 1, 2])
            quadrants = T[-Inf, -1, -0.0, 0.0, 1, Inf]
            compare_batch(atan, quadrants, reverse(quadrants))
            compare_batch(DF.atanxy, quadrants, reverse(quadrants))
        end
        x = vcat(bounded(0.005, 0.09), Double64[NaN, -0.0, 0.0, 10.0])
        # cis returns a real value for NaN. Keep the conversion in the test.
        reference = cis.(x)
        mixed = Vector{Union{Double64,ComplexDF64}}(undef, length(x))
        simdmap!(cis, mixed, x)
        @test all(same_limbs.(mixed, reference))
        complex_dest = Vector{ComplexDF64}(undef, length(x))
        simdmap!(cis, complex_dest, x)
        @test all(same_limbs.(complex_dest, ComplexDF64.(reference)))

        exponents = Double64[Double64(-1075.0), Double64(-1075.0, 1e-30),
                             Double64(-1075.0, -1e-30), Double64(-1022), Double64(1024)]
        y = compare_batch(exp2, exponents)
        setprecision(256) do
            expected = Float64[Float64(exp2(BigFloat(HI(x)) + BigFloat(LO(x)))) for x in exponents]
            @test HI.(y) == expected
            pole = Double64("1.57079632679489661923132169163975")
            angles = Double64[Double64(HI(pole), prevfloat(LO(pole))), pole,
                              Double64(HI(pole), nextfloat(LO(pole)))]
            for (x, t) in zip(angles, compare_batch(tan, angles))
                exact = tan(BigFloat(HI(x)) + BigFloat(LO(x)))
                @test abs((BigFloat(HI(t)) + BigFloat(LO(t))) / exact - 1) < BigFloat(2)^(-68)
            end
        end
    end

    @testset "Axes, storage and write order" begin
        @test isempty(simdmap!(exp, Double64[], Double64[]))
        for n in (1, 7, 63, 64, 65, 128, 133)
            compare_batch(exp, fill(Double64(1.25), n))
        end
        x = Double64.(1:130) ./ 8
        compare_batch(exp, view(x, 2:2:130))
        out = view(fill(Double64(-1), 136), 1:2:136)
        source = view(x, 1:65)
        @test_throws DimensionMismatch simdmap!(sin, out, source)
        @test all(==(-1), parent(out))
        @test_throws DimensionMismatch simdmap!(atan, zeros(Double64, 130), x, source)
        @test_throws DimensionMismatch simdmap!(sin, similar(x), ShiftedVector(x))
        dest = ShiftedVector(similar(x))
        @test simdmap!(sin, dest, ShiftedVector(x)) === dest
        @test all(same_limbs.(dest.storage, sin.(x)))
        aliased = copy(x)
        simdmap!(exp, ShiftedVector(aliased), ShiftedVector(aliased))
        @test all(same_limbs.(aliased, exp.(x)))
        for (destidx, srcidx) in ((2:130, 1:129), (1:129, 2:130), (1:130, 1:130))
            for (f, args) in ((sin, ()), (^, (5,)), (atan, (fill(Double64(2), length(srcidx)),)))
                data = copy(x)
                out, input = view(data, destidx), view(data, srcidx)
                expected = f.(copy(input), map(a -> a isa Number ? Ref(a) : a, args)...)
                @test simdmap!(f, out, input, args...) === out
                @test all(same_limbs.(out, expected))
            end
        end
        exponents = copy(x)
        base = fill(Double64(1.25), length(x))
        simdmap!(^, exponents, base, exponents)
        @test all(same_limbs.(exponents, base .^ x))
        wrapped = copy(x)
        GC.@preserve wrapped begin
            a = unsafe_wrap(Vector{Double64}, pointer(wrapped), 129)
            b = unsafe_wrap(Vector{Double64}, pointer(wrapped, 2), 129)
            simdmap!(sin, b, a)
            @test all(same_limbs.(b, sin.(x[1:129])))
        end

        valid = Double64(1.025)
        invalid = fill(valid, 150)
        invalid[95] = Double64(-1)
        out = fill(Double64(-1), length(invalid))
        @test_throws DomainError simdmap!(log, out, invalid)
        @test all(same_limbs.(out[1:94], log(valid)))
        @test all(==(-1), out[95:end])
        ints = fill(-1, 3)
        @test_throws InexactError simdmap!(identity, ints, [1.0, 0.5, 2.0])
        @test ints == [1, -1, -1]
        narrow = Vector{Double32}(undef, length(x))
        simdmap!(exp, narrow, x)
        @test all(same_limbs.(narrow, convert.(Double32, exp.(x))))
    end

    @testset "Allocation-free dense serial paths" begin
        x = fill(Double64(0.03125, -1e-20), 128)
        @test iszero(batch_allocations(exp2, similar(x), x))
        @test iszero(batch_allocations(sincos, Vector{Tuple{Double64,Double64}}(undef, length(x)), x))
        @test iszero(batch_allocations(^, similar(x), fill(Double64(1.125), length(x)), 5))
        z = complex.(Double64(1.5), x)
        @test iszero(batch_allocations(exp, similar(z), z))
    end

    @testset "Optional threads" begin
        positive = repeat(bounded(1.1, 1.5), 129)
        compare_batch(exp, positive; threaded=true)
        compare_batch(atan, positive, reverse(positive); threaded=true)
        compare_batch(hypot, positive, -positive; threaded=true)
        compare_batch(DF.normalize, -positive, positive; threaded=true)
        compare_batch(inv, repeat(positive, 4); threaded=true)
        compare_batch(sinpi, positive; threaded=true)
        compare_batch(exp, complex.(positive, Double64(0.03125)); threaded=true)
        compare_batch(sincos, fill(Double64(0.03125), length(positive)); threaded=true)
        compare_batch(^, positive, 5; threaded=true)
        compare_batch(exp, positive[1:1]; threaded=true)
        @test fetch(Threads.@spawn begin
            out = similar(positive)
            simdmap!(exp, out, positive; threaded=true)
            all(same_limbs.(out, exp.(positive)))
        end)

        invalid = copy(positive)
        invalid[95] = Double64(-1)
        out = fill(Double64(-1), length(invalid))
        if Threads.nthreads() > 1
            @test_throws CompositeException simdmap!(log, out, invalid; threaded=true)
            @test same_limbs(out[end], log(invalid[end]))
        else
            @test_throws DomainError simdmap!(log, out, invalid; threaded=true)
            @test out[end] == -1
        end
        calls = Int[]
        f(x) = (push!(calls, Int(x)); x)
        xs = collect(1:17000)
        simdmap!(f, similar(xs), xs; threaded=true)
        @test calls == xs
    end
end

end
