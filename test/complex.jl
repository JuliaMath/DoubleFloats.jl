f0 = Complex(0.0, 0.0)
f1 = Complex(1.0, 0.0)
f1i = Complex(0.0, 1.0)
f11 = Complex(1.0, 1.0)
f2h = Complex(2.0, 0.5)

d0 = Complex(Double64(0), Double64(0))
d1 = Complex(Double64(1), Double64(0))
d1i = Complex(Double64(0), Double64(1))
d11 = Complex(Double64(1), Double64(1))
d2h = Complex(Double64(2), Double64(0.5))

@testset "Complex" begin
  @test isapprox(log(f11), Complex{Float64}(log(d11)))
  @test isapprox(exp(f11), Complex{Float64}(exp(d11)))
  
  @test isapprox(sin(f11), Complex{Float64}(sin(d11)))
  @test isapprox(cos(f11), Complex{Float64}(cos(d11)))
  @test isapprox(tan(f11), Complex{Float64}(tan(d11)))
  @test isapprox(csc(f11), Complex{Float64}(csc(d11)))
  @test isapprox(sec(f11), Complex{Float64}(sec(d11)))
  @test isapprox(cot(f11), Complex{Float64}(cot(d11)))

  @test isapprox(sinh(f11), Complex{Float64}(sinh(d11)))
  @test isapprox(cosh(f11), Complex{Float64}(cosh(d11)))
  @test isapprox(tanh(f11), Complex{Float64}(tanh(d11)))
  @test isapprox(csch(f11), Complex{Float64}(csch(d11)))
  @test isapprox(sech(f11), Complex{Float64}(sech(d11)))
  @test isapprox(coth(f11), Complex{Float64}(coth(d11)))
  
  @test isapprox(asin(f11), Complex{Float64}(asin(d11)))
  @test isapprox(acos(f11), Complex{Float64}(acos(d11)))
  @test isapprox(atan(f2h), Complex{Float64}(atan(d2h)))
  @test isapprox(acsc(f11), Complex{Float64}(acsc(d11)))
  @test isapprox(asec(f11), Complex{Float64}(asec(d11)))
  @test isapprox(acot(f2h), Complex{Float64}(acot(d2h)))

  @test isapprox(asinh(f11), Complex{Float64}(asinh(d11)))
  @test isapprox(acosh(f11), Complex{Float64}(acosh(d11)))
  @test isapprox(atanh(f11), Complex{Float64}(atanh(d11)))
  @test isapprox(acsch(f11), Complex{Float64}(acsch(d11)))
  @test isapprox(asech(f11), Complex{Float64}(asech(d11)))
  @test isapprox(acoth(f11), Complex{Float64}(acoth(d11)))
end


@testset "Complex Accuracy" begin
  x = ComplexDF64(sqrt(df64"2"), cbrt(df64"3"))
  y = Complex{BigFloat}(x)
  
  @test abs(sin(y) - sin(x)) < 1.0e-31
  @test abs(cos(y) - cos(x)) < 1.0e-31
  @test abs(tan(y) - tan(x)) < 1.0e-31
  @test abs(csc(y) - csc(x)) < 1.0e-31
  @test abs(sec(y) - sec(x)) < 1.0e-31
  @test abs(tan(y) - tan(x)) < 1.0e-31

  @test abs(sinh(y) - sinh(x)) < 1.0e-31
  @test abs(cosh(y) - cosh(x)) < 1.0e-31
  @test abs(tanh(y) - tanh(x)) < 1.0e-31
  @test abs(csch(y) - csch(x)) < 1.0e-31
  @test abs(sech(y) - sech(x)) < 1.0e-31
  @test abs(tanh(y) - tanh(x)) < 1.0e-31

  @test abs(asin(y) - asin(x)) < 1.0e-31
  @test abs(acos(y) - acos(x)) < 1.0e-31
  @test abs(atan(y) - atan(x)) < 1.0e-31
  @test abs(acsc(y) - acsc(x)) < 1.0e-31
  @test abs(asec(y) - asec(x)) < 1.0e-31
  @test abs(atan(y) - atan(x)) < 1.0e-31

  @test abs(asinh(y) - asinh(x)) < 1.0e-31
  @test abs(acosh(y) - acosh(x)) < 1.0e-31
  @test abs(atanh(y) - atanh(x)) < 1.0e-31
  @test abs(acsch(y) - acsch(x)) < 1.0e-31
  @test abs(asech(y) - asech(x)) < 1.0e-31
  @test abs(atanh(y) - atanh(x)) < 1.0e-31

end

@testset "Complex exp(huge)" begin
    x = Double64(-1.168869267851442e79) + Double64(4.140780141319954e87)*im
    @test ComplexDF64(exp(x)) == exp(ComplexDF64(x))
end
