i2 = 2
f2 = 2.0
d2 = Double64(2.0)
b2 = BigFloat(2)
r2 = 2//1
i3 = 3
f3 = 3.0
d3 = Double64(3.0)
b3 = BigFloat(3)
r3 = 3//1

small = Double64(0.25*eps(1.0))
gt1 = one(Double64) + small
lt1 = one(Double64) - small

@testset "compare" begin
  @test d2 == d2
  @test d2 != d3
  @test d2 <  d3
  @test d2 <= d3
  @test d3 >  d2
  @test d3 >= d2
  @test isless(d2, d3)
  @test isequal(d2, d2)
  
  @test d2 == i2
  @test d2 != i3
  @test d2 <  i3
  @test d2 <= i3
  @test d3 >  i2
  @test d3 >= i2
  @test isless(d2, i3)
  @test isequal(d2, i2)
  
  @test i2 == d2
  @test i2 != d3
  @test i2 <  d3
  @test i2 <= d3
  @test i3 >  d2
  @test i3 >= d2
  @test isless(i2, d3)
  @test isequal(i2, d2)

  
  @test d2 == f2
  @test d2 != f3
  @test d2 <  f3
  @test d2 <= f3
  @test d3 >  f2
  @test d3 >= f2
  @test isless(d2, f3)
  @test isequal(d2, f2)
  
  @test f2 == d2
  @test f2 != d3
  @test f2 <  d3
  @test f2 <= d3
  @test f3 >  d2
  @test f3 >= d2
  @test isless(f2, d3)
  @test isequal(f2, d2)

  
  @test d2 == b2
  @test d2 != b3
  @test d2 <  b3
  @test d2 <= b3
  @test d3 >  b2
  @test d3 >= b2
  @test isless(d2, b3)
  @test isequal(d2, b2)
  
  @test b2 == d2
  @test b2 != d3
  @test b2 <  d3
  @test b2 <= d3
  @test b3 >  d2
  @test b3 >= d2
  @test isless(b2, d3)
  @test isequal(b2, d2)

  
  @test d2 == r2
  @test d2 != r3
  @test d2 <  r3
  @test d2 <= r3
  @test d3 >  r2
  @test d3 >= r2
  @test isless(d2, r3)
  @test isequal(d2, r2)
  
  @test r2 == d2
  @test r2 != d3
  @test r2 <  d3
  @test r2 <= d3
  @test r3 >  d2
  @test r3 >= d2
  @test isless(r2, d3)
  @test isequal(r2, d2)

end


@testset "compare to tuple" begin
  @test d2 == HILO(d2)
  @test d2 != HILO(d3)
  @test d2 <  HILO(d3)
  @test d2 <= HILO(d3)
  @test d3 >  HILO(d2)
  @test d3 >= HILO(d2)
  @test isless(d2, HILO(d3))
  @test isequal(d2, HILO(d2))
  
  @test HILO(d2) == d2
  @test HILO(d2) != d3
  @test HILO(d2) <  d3
  @test HILO(d2) <= d3
  @test HILO(d3) >  d2
  @test HILO(d3) >= d2
  @test isless(HILO(d2), d3)
  @test isequal(HILO(d2), d2)  
end

@testset "compare issue 49" begin
  @test gt1 > 1.0
  @test !(gt1 < 1.0)
  @test lt1 < 1.0
  @test !(lt1 > 1.0)
end
