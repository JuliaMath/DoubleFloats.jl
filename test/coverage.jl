@testset "convert" begin

bf = BigFloat(pi)
df = Double64(bf)
sqrt2 = sqrt(2.0)

@test BigFloat(df) == convert(BigFloat, df)
@test Double64(bf) == convert(Double64, bf)

@test Double32(sqrt2) == convert(Double32, sqrt2)
@test Double64(sqrt2) == convert(Double64, sqrt2)

end # convert
@testset "maxintfloat $T" for T in (Double32, Double64)
    @test isinteger(maxintfloat(T))

    # Previous integer is representable, next integer is not
    @test maxintfloat(T) == (maxintfloat(T) - one(T)) + one(T)
    @test maxintfloat(T) != (maxintfloat(T) + one(T)) - one(T)
end

@testset "predicates $T" for T in (Double32, Double64)
  
    @test iszero(zero(T))
    @test isone(one(T))
    @test ispos(one(T))
    @test isneg(-one(T))
    @test isnonpos(-one(T))
    @test isnonpos(zero(T))
    @test isnonneg(one(T))
    @test isnonneg(zero(T))
  
    @test isinf(T(Inf))
    @test isposinf(T(Inf))
    @test isneginf(T(-Inf))
    @test isnan(T(NaN))
  
    @test isnormal(one(T))
    @test isinteger(one(T))
    @test isfractional(one(T)/2)
  
end # predicates

@testset "Double $T" for T in (Double16, Double32, Double64)

    @test HI(one($T)) == one($T)
    @test LO(one($T)) == zero($T)
    @test HILO(one($T)) == (one($T), zero($T))
    
    sqrt2  = sqrt($T(2))
    hi, lo = sqrt2.hi, sqrt2.lo
    hilo   = HILO(sqrt2)
    
    @test HI(sqrt2) == hi
    @test LO(sqrt2) == lo
    @test HILO(sqrt2) == (hi, lo)
    
    @test HI(hilo) == hi
    @test LO(hilo) == lo
    @test HILO(hilo) == hilo
    
end # Double
