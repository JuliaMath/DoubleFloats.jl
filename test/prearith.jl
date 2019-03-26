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

@testset "trunc $T" for T in (Double16, Double32, Double64)
   for I in (:Int16, :Int32, :Int64, :Int128)
       @test 3 == @eval trunc($I, $T(pi))
   end
end

@testset "floor $T" for T in (Double16, Double32, Double64)
   for I in (:Int16, :Int32, :Int64, :Int128)
       @test 3 == @eval floor($I, $T(pi))
   end
end

@testset "ceil $T" for T in (Double16, Double32, Double64)
   for I in (:Int16, :Int32, :Int64, :Int128)
       @test 4 == @eval ceil($I, $T(pi))
   end
end

@testset "round $T" for T in (Double16, Double32, Double64)
   for I in (:Int16, :Int32, :Int64, :Int128)
       @test 3 == @eval round($I, $T(pi), RoundNearest)
       @test 3 == @eval round($I, $T(pi), RoundNearestTiesAway)
       @test 4 == @eval round($I, $T(pi), RoundUp)
       @test 3 == @eval round($I, $T(pi), RoundDown)
       @test 3 == @eval round($I, $T(pi), RoundToZero)
   end
end


@testset "spread $T" for T in (Double16, Double32, Double64)
    @test 4 == @eval spread($T(pi))
end

@testset "sld $T" begin
    @test 7.0 == @eval sld(Double64(pi), 0.5)
end

@testset "tld $T" begin
    @test 6.0 == @eval tld(Double64(pi), 0.5)
end

