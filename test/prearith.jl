@testset "prearith $T" for T in (Double16, Double32, Double64)
  
    val = T(17)/3
  
    @test -T(1) == T(-1)
    @test abs(T(-1)) == T(1)
    @test abs(T(1)) == T(1)
    @test flipsign(T(1), -1) == T(-1)
    @test flipsign(T(1), 1) == T(1)
    
    @test ldexp(frexp(val)...,) == val
    @test ldexp(significand(val), exponent(val)) == val
    @test signs(val) = sign(HI(val)), sign(LO(val))
end
