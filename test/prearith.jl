@testset "prearith $T" for T in (Double16, Double32, Double64)
  
    @test -T(1) == T(-1)
    @test abs(T(-1)) == T(1)
    @test abs(T(1)) == T(1)
    @test flipsign(T(1), -1) == T(-1)
    @test flipsign(T(1), 1) == T(1)
    
    @test ldexp(frexp(T(pi))...,) == T(pi)
    @test ldexp(significand(T(pi)), exponent(T(pi))) == T(pi)
    @test signs(T(pi)) = sign(HI(T(pi))), sign(LO(T(pi)))
end
