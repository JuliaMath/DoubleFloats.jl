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
    @test ispositive(one(T))
    @test isnegative(-one(T))
    @test isnonpositive(-one(T))
    @test isnonpositive(zero(T))
    @test isnonnegative(one(T))
    @test isnonnegative(zero(T))
  
    @test isinf(T(Inf))
    @test isposinf(T(Inf))
    @test isneginf(T(-Inf))
    @test isnan(T(NaN))
  
    @test isnormal(one(T))
    @test isinteger(one(T))
    @test isfractional(one(T)/2)
  
end # predicates

@testset "double $T" for T in (Double32, Double64)

    @test HI(one(T)) == one(T)
    @test LO(one(T)) == zero(T)
    @test HILO(one(T)) == (one(T), zero(T))
    
    sqrt2  = sqrt(T(2))
    hi, lo = sqrt2.hi, sqrt2.lo
    hilo   = HILO(sqrt2)
    
    @test HI(sqrt2) == hi
    @test LO(sqrt2) == lo
    @test HILO(sqrt2) == (hi, lo)
    
    @test HI(hilo) == hi
    @test LO(hilo) == lo
    @test HILO(hilo) == hilo
        
end # Double

@testset "compare $T" for T in (Double32, Double64)

    two = 2
    fp2 = T(2)
    sqrt2  = sqrt(T(2))
    sqrt5  = sqrt(T(5))
    
    @test   sqrt2 == sqrt2
    @test   sqrt2 >= sqrt2
    @test   sqrt2 <= sqrt2
    @test !(sqrt2 != sqrt2)
    @test !(sqrt2 >  sqrt2)
    @test !(sqrt2 <  sqrt2)

    @test !(sqrt2 == sqrt5)
    @test !(sqrt2 >= sqrt5)
    @test   sqrt2 <= sqrt5
    @test   sqrt2 != sqrt5
    @test !(sqrt2 >  sqrt5)
    @test   sqrt2 <  sqrt5

    @test !(fp2 == sqrt5)
    @test !(fp2 >= sqrt5)
    @test   fp2 <= sqrt5
    @test   fp2 != sqrt5
    @test !(fp2 >  sqrt5)
    @test   fp2 <  sqrt5

    @test !(sqrt5 == fp2)
    @test !(sqrt5 <= fp2)
    @test   sqrt5 >= fp2
    @test   sqrt5 != fp2
    @test !(sqrt5 <  fp2)
    @test   sqrt5 >  fp2

    @test !(two == sqrt5)
    @test !(two >= sqrt5)
    @test   two <= sqrt5
    @test   two != sqrt5
    @test !(two >  sqrt5)
    @test   two <  sqrt5

    @test !(sqrt5 == two)
    @test !(sqrt5 <= two)
    @test   sqrt5 >= two
    @test   sqrt5 != two
    @test !(sqrt5 <  two)
    @test   sqrt5 >  two    
    
end # compare
