f0 = Complex(0.0, 0.0)
f1 = Complex(1.0, 0.0)
f1i = Complex(0.0, 1.0)

d0 = Complex(Double64(0), Double64(0))
d1 = Complex(Double64(1), Double64(0))
d1i = Complex(Double64(0), Double64(1))

@testset "Complex" begin
  @test isapprox(sin(f0), Complex{Float64}(sin(d0)))
  @test isapprox(cos(f0), Complex{Float64}(cos(d0)))
  @test isapprox(tan(f0), Complex{Float64}(tan(d0)))
  @test isapprox(csc(f1), Complex{Float64}(csc(d1)))
  @test isapprox(sec(f0), Complex{Float64}(sec(d0)))
  @test isapprox(cot(f1), Complex{Float64}(cot(d1)))

  @test isapprox(sinh(f0), Complex{Float64}(sinh(d0)))
  @test isapprox(cosh(f0), Complex{Float64}(cosh(d0)))
  @test isapprox(tanh(f0), Complex{Float64}(tanh(d0)))
  @test isapprox(csch(f1), Complex{Float64}(csch(d1)))
  @test isapprox(sech(f0), Complex{Float64}(sech(d0)))
  @test isapprox(coth(f1), Complex{Float64}(coth(d1)))

  
  @test isapprox(asin(f0), Complex{Float64}(asin(d0)))
  @test isapprox(acos(f0), Complex{Float64}(acos(d0)))
  @test isapprox(atan(f0), Complex{Float64}(atan(d0)))
#=
  @test isapprox(acsc(f1), Complex{Float64}(acsc(d1)))
  @test isapprox(asec(f1), Complex{Float64}(asec(d1)))
  @test isapprox(acot(f11), Complex{Float64}(acot(d11)))

  @test isapprox(sinh(f0), Complex{Float64}(sinh(d0)))
  @test isapprox(cosh(f0), Complex{Float64}(cosh(d0)))
  @test isapprox(tanh(f0), Complex{Float64}(tanh(d0)))
  @test isapprox(csch(f1), Complex{Float64}(csch(d1)))
  @test isapprox(sech(f0), Complex{Float64}(sech(d0)))
  @test isapprox(coth(f1), Complex{Float64}(coth(d1)))

  @test isapprox(asinh(f0), Complex{Float64}(asinh(d0)))
  @test isapprox(acosh(f0), Complex{Float64}(acosh(d0)))
  @test isapprox(atanh(f0), Complex{Float64}(atanh(d0)))
  @test isapprox(acsch(f0), Complex{Float64}(acsch(d0)))
  @test isapprox(asech(f0), Complex{Float64}(asech(d0)))
  @test isapprox(acoth(f0), Complex{Float64}(acoth(d0)))
=#
end
