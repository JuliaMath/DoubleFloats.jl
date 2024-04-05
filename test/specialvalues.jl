@testset "maxintfloat $T" for T in (Double16, Double32, Double64)
    @test isinteger(maxintfloat(T))

    # Previous integer is representable, next integer is not
    @test maxintfloat(T) == (maxintfloat(T) - one(T)) + one(T)
    @test maxintfloat(T) != (maxintfloat(T) + one(T)) - one(T)
    
    @test maxintfloat(T) < floatmax(T)
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
end

@testset "Inf and NaN layout $T" for T in (Double16, Double32, Double64)
    @test isinf(HI(T(Inf)))
    @test isnan(HI(T(NaN)))
    @test isinf(LO(T(Inf)))
    @test isnan(LO(T(NaN)))
end

@testset "Inf and NaN conversion" for T in (Double16, Double32, Double64)
    for S in (BigFloat, Float128)
        @test isnan(S(T(NaN)))
        @test isinf(S(T(Inf)))
        @test S(T(Inf)) > 0
        @test isinf(S(T(-Inf)))
        @test S(T(-Inf)) < 0
        @test isnan(T(S(NaN)))
        @test isinf(T(S(Inf)))
        @test T(S(Inf)) > 0
        @test isinf(T(S(-Inf)))
        @test T(S(-Inf)) < 0
    end
end

@testset "NaNs $T" for T in (Double16, Double32, Double64)
    @test isnan(exp(T(NaN)))
    @test isnan(log(T(NaN)))
    @test isnan(sin(T(NaN)))
    @test isnan(cos(T(NaN)))
    @test isnan(tan(T(NaN)))
    @test isnan(csc(T(NaN)))
    @test isnan(sec(T(NaN)))
    @test isnan(cot(T(NaN)))
    @test isnan(asin(T(NaN)))
    @test isnan(acos(T(NaN)))
    @test isnan(atan(T(NaN)))
    @test isnan(acsc(T(NaN)))
    @test isnan(asec(T(NaN)))
    @test isnan(acot(T(NaN)))
    @test isnan(sinh(T(NaN)))
    @test isnan(cosh(T(NaN)))
    @test isnan(tanh(T(NaN)))
    @test isnan(csch(T(NaN)))
    @test isnan(sech(T(NaN)))
    @test isnan(coth(T(NaN)))
    @test isnan(asinh(T(NaN)))
    @test isnan(acosh(T(NaN)))
    @test isnan(atanh(T(NaN)))
    @test isnan(acsch(T(NaN)))
    @test isnan(asech(T(NaN)))
    @test isnan(acoth(T(NaN)))
end
    
@testset "floatmin2 $T" for T in (Double16, Double32, Double64)
    trueval = (twopar = 2one(T); twopar^trunc(Integer,log(floatmin(T)/eps(T))/log(twopar)/twopar))
    @test LinearAlgebra.floatmin2(T) == trueval 
end         
