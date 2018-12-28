@testset "maxintfloat $T" for T in (Double16, Double32, Double64)
    @test isinteger(maxintfloat(T))

    # Previous integer is representable, next integer is not
    @test maxintfloat(T) == (maxintfloat(T) - one(T)) + one(T)
    @test maxintfloat(T) != (maxintfloat(T) + one(T)) - one(T)

    @test maxintfloat(T) < floatmax(T)
end

@testset "Zeros $T" for T in (Double64, Double32, Double16)
    Zero = zero(T)
    One = one(T)
    Half = T(1/2)
    mZero = -Zero
    tiny = floatmin(T)
    @test Zero == T(0)
    @test Zero == T(0.0)
    @test_broken Zero == mZero
    @test ! (Zero === mZero) # note identity
    @test ! (Zero < mZero)
    @test ! (mZero < Zero)
    @test tiny > Zero
    @test (-tiny) < mZero
    @test Zero^1 == Zero
    @test_broken mZero^1 == Zero
    @test Zero^One == Zero
    @test_broken Zero^Half == Zero
    @test isnan(Zero/Zero)
    pinf = T(Inf)
    minf = T(-Inf)
    @test_broken One/Zero == pinf
    @test_broken One/mZero == minf
    @test_broken inv(Zero) == pinf
    @test_broken inv(mZero) == minf
    @test isnan(rem(One,Zero))

    # this is mandated by IEEE-754, defended by Knuth and Kahan
    @test_broken Zero^Zero == One
end

@testset "Inf and NaN generation $T" for T in (Double16, Double32, Double64)
    @test isinf(T(Inf)) == isinf(inf(T))
    @test isinf(T(Inf)) == isposinf(posinf(T))
    @test isinf(T(-Inf)) == isneginf(neginf(T))
    @test isnan(T(NaN)) == isnan(nan(T))

    @test isinf(T(Inf32)) == isinf(inf(T))
    @test isinf(T(Inf32)) == isposinf(posinf(T))
    @test isinf(T(-Inf32)) == isneginf(neginf(T))
    @test isnan(T(NaN32)) == isnan(nan(T))

    @test isinf(T(Inf16)) == isinf(inf(T))
    @test isinf(T(Inf16)) == isposinf(posinf(T))
    @test isinf(T(-Inf16)) == isneginf(neginf(T))
    @test isnan(T(NaN16)) == isnan(nan(T))

    huge = floatmax(T)
    mhuge = -huge
    pinf = huge*huge
    minf = huge*mhuge
    @test isinf(pinf)
    @test isinf(minf)
    @test_broken pinf == T(Inf)
    @test_broken minf == T(-Inf)
    @test_broken pinf == -minf
    @test_broken isinf(square(mhuge))
    @test_broken isinf(cube(mhuge))
    @test isinf(huge+huge)
    @test isinf(mhuge+mhuge)
    @test_broken (huge + eps(huge)) - huge >= 0
end

@testset "Inf arithmetic $T" for T in (Double64, Double32, Double16)
    huge = floatmax(T)
    mhuge = -huge
    pinf = huge*huge
    minf = huge*mhuge
    @test pinf > huge
    @test minf < (-huge)
    @test isnan(pinf-Inf)
    @test isnan(Inf+minf)
    @test isnan(pinf + minf)
    @test pinf+pinf == pinf
    @test pinf*pinf == pinf
    @test minf*minf == pinf
    @test minf+minf == minf
    @test isnan(pinf/pinf)
    @test isnan(minf/pinf)
    @test isnan(pinf/minf)
    @test isnan(minf/minf)
    One = one(T)
    Zero = zero(T)
    mZero = -Zero
    @test One/pinf === Zero
    @test_broken inv(pinf) === Zero
    @test One/minf === mZero
    @test_broken inv(minf) === mZero
    @test !(One/minf === Zero)
    @test !(inv(minf) === Zero)
    @test_broken square(pinf) == pinf
    @test_broken square(minf) == pinf
    @test_broken cube(pinf) == pinf
    @test_broken cube(minf) == minf
    @test isnan(rem(pinf,One))
    @test isnan(rem(minf,One))
    # do we need to test all of the signs?
    @test isnan(Zero*pinf)
end

@testset "NaN $T" for T in (Double64, Double32, Double16)
    huge = floatmax(T)
    mhuge = -huge
    pinf = huge*huge
    minf = huge*mhuge
    xnan = pinf+minf
    @test_broken !(xnan == xnan)
    # a famous special case
    @test isinf(hypot(pinf, xnan))
    @test isinf(hypot(minf, xnan))
    One = T(1)
    Zero = T(0)
    for op in (+,-,*)
        @test isnan(op(Zero,xnan))
        @test isnan(op(0,xnan))
        @test isnan(op(One,xnan))
        @test isnan(op(1,xnan))
    end
end

@testset "Huge $T" for T in (Double32, Double16)
    huge = floatmax(T)
    @test isfinite(log(huge))
end
# merge this when they all work
@testset "Huge $T" for T in (Double64, )
    huge = floatmax(T)
    @test_broken isfinite(log(huge))
end

@testset "Underflow $T" for T in (Double64, Double32, Double16)
    tiny = floatmin(T)
    Half = T(1/2)
    @test (Half*tiny) < tiny
    @test (tiny*tiny) < tiny
    @test square(tiny) < tiny
    @test cube(tiny) < tiny
end
