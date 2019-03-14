@testset "prearith $T" for T in (Double16, Double32, Double64)
  
    val = T(17)/3
    negval = -val
  
    @test -val == negval
    @test abs(val) == val
    @test abs(negval) == val
    @test flipsign(val, -1) == negval
    @test flipsign(negval, 1) == negval
    
    @test ldexp(frexp(val)...,) == val
   # @test ldexp(significand(val), exponent(val)) == val
  
    @test signs(val) == (sign(HI(val)), sign(LO(val)))

end
