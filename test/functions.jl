@testset "Strings" begin
    @test LO(sqrt(df64"2")) < LO(nextfloat(sqrt(df64"2")))
end

@testset "Adjacent values" begin
    @test nextfloat(Double64(10))  > Double64(10)
    @test nextfloat(Double32(-10)) > Double32(-10)
    @test prevfloat(Double64(10))  < Double64(10)
    @test prevfloat(Double32(-10)) < Double32(-10)    
    @test nextfloat(Double64(10),3)  > nextfloat(Double64(10),2)
    @test nextfloat(Double32(-10),3) > nextfloat(Double32(-10),2)
    @test prevfloat(Double64(10),3)  < prevfloat(Double64(10),2)
    @test prevfloat(Double32(-10),3) < prevfloat(Double32(-10),2)
end

@testset "power functions"  begin
    @test Double64(10.0)^0 == Double64(1.0)
    @test Double64(10.0)^1 == Double64(10.0)
    @test Double64(0.0)^0 == Double64(1.0)
end

f64a = sqrt(2.0)
f64b = sqrt(2.0)/2
d64a = sqrt(Double64(2.0))
d64b = sqrt(Double64(2.0))/2

@testset "log exp functions" begin
   @test isapprox(log(f64a), log(d64a))
   @test isapprox(log2(f64a), log2(d64a))
   @test isapprox(log10(f64a), log10(d64a))
   @test isapprox(log1p(f64a), log1p(d64a))
   @test isapprox(exp(f64a), exp(d64a))
   @test isapprox(exp2(f64a), exp2(d64a))
   @test isapprox(exp10(f64a), exp10(d64a))
   @test isapprox(expm1(f64a), expm1(d64a))    
end

@testset "trig functions" begin
   @test isapprox(sin(f64a), sin(d64a))
   @test isapprox(cos(f64a), cos(d64a))
   @test isapprox(tan(f64a), tan(d64a))
   @test isapprox(csc(f64a), csc(d64a))
   @test isapprox(sec(f64a), sec(d64a))
   @test isapprox(cot(f64a), cot(d64a))
   @test isapprox(asin(f64b), asin(d64b))
   @test isapprox(acos(f64b), acos(d64b))
   @test isapprox(atan(f64a), atan(d64a))
   @test isapprox(acsc(f64a), acsc(d64a))
   @test isapprox(asec(f64a), asec(d64a))
   @test isapprox(acot(f64a), acot(d64a))
end

@testset "hyperbolic trig functions" begin
   @test isapprox(sinh(f64a), sinh(d64a))
   @test isapprox(cosh(f64a), cosh(d64a))
   @test isapprox(tanh(f64a), tanh(d64a))
   @test isapprox(csch(f64a), csch(d64a))
   @test isapprox(sech(f64a), sech(d64a))
   @test isapprox(coth(f64a), coth(d64a))
   @test isapprox(asinh(f64b), asinh(d64b))
   @test isapprox(acosh(f64a), acosh(d64a))
   @test isapprox(atanh(f64b), atanh(d64b))
   @test isapprox(acsch(f64b), acsch(d64b))
   @test isapprox(asech(f64b), asech(d64b))
   @test isapprox(acoth(f64a), acoth(d64a))
end

