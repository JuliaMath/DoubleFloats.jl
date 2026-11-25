@testset "convert" begin

    one = 1
    bf = BigFloat(pi)
    df = Double64(bf)
    sqrt2 = sqrt(2.0)

    @test BigFloat(df) == convert(BigFloat, df)
    @test Double64(bf) == convert(Double64, bf)

    @test Double32(sqrt2) == convert(Double32, sqrt2)
    @test Double64(sqrt2) == convert(Double64, sqrt2)

    @test one == convert(Int, Double64(1))
    @test BigInt(one) == convert(BigInt, Double32(1))
    @test Double16(1) == convert(Double16, BigInt(1))

    x = rand()
    @test convert(Double64, x) isa Double64
    allocs = @allocated convert(Double64, x)
    @test allocs == 0

    x32 = rand(Float32)
    allocs32 = @allocated convert(Double64, x32)
    @test allocs32 == 0

    z = rand(ComplexF64)
    @test convert(ComplexDF64, z) isa ComplexDF64
    allocs = @allocated convert(ComplexDF64, z)
    @test allocs == 0
end # convert

@testset "construct $T" for T in (Double16, Double32, Double64)

    i5 = 5
    five = T(5)

    @test Int64(i5) == Int64(five)
    @test Int32(i5) == Int32(five)
    @test Int16(i5) == Int16(five)
    @test Float64(i5) == Float64(five)
    @test Float32(i5) == Float32(five)
    @test Float16(i5) == Float16(five)
    @test five == T(BigFloat(i5))
    @test five == T(BigInt(i5))

    @test five == T(five)
    @test five == T(T(five))
end

@testset "maxintfloat $T" for T in (Double16, Double32, Double64)
    @test isinteger(maxintfloat(T))

    # Previous integer is representable, next integer is not
    @test maxintfloat(T) == (maxintfloat(T) - one(T)) + one(T)
    @test maxintfloat(T) != (maxintfloat(T) + one(T)) - one(T)
end

@testset "predicates $T" for T in (Double16, Double32, Double64)

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

@testset "double $T" for T in (Double16, Double32, Double64)

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

@testset "compare $T" for T in (Double16, Double32, Double64)

    one = 1
    fp1 = T(1)
    two = 2.0
    fp2 = T(2)
    sqrt2  = sqrt(T(2))
    sqrt5  = sqrt(T(5))

    @test isequal(sqrt2, sqrt2)
    @test isless(sqrt2, sqrt5)

    @test sqrt5 != two
    @test two != sqrt5
    @test two == fp2
    @test fp2 == two
    @test two < sqrt5
    @test !(sqrt5 < two)
    @test two <= sqrt5
    @test !(sqrt5 <= two)
    @test !(two > sqrt5)
    @test sqrt5 > two
    @test !(two >= sqrt5)
    @test sqrt5 >= two

    @test sqrt5 != one
    @test one != sqrt5
    @test fp1 == one
    @test one == fp1
    @test one < sqrt5
    @test !(sqrt5 < one)
    @test one <= sqrt5
    @test !(sqrt5 <= one)
    @test !(one > sqrt5)
    @test sqrt5 > one
    @test !(one >= sqrt5)
    @test sqrt5 >= one

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

@testset "eps $T" for T in (Double16, Double32, Double64)
    fp2 = T(2)
    sqrt2  = sqrt(T(2))

    @test eps(fp2) >= DoubleFloats.ulp(fp2)
    @test eps(sqrt2) >= DoubleFloats.ulp(sqrt2)

    @test nextfloat(fp2) > fp2
    @test nextfloat(sqrt2) > sqrt2

    @test prevfloat(fp2) < fp2
    @test prevfloat(sqrt2) < sqrt2

    @test nextfloat(-fp2) > -fp2
    @test nextfloat(-sqrt2) > -sqrt2

    @test prevfloat(-fp2) < -fp2
    @test prevfloat(-sqrt2) < -sqrt2

    @test nextfloat(fp2,2) > fp2
    @test nextfloat(sqrt2,2) > sqrt2

    @test nextfloat(fp2,3) > nextfloat(fp2,2)
    @test prevfloat(fp2,3) < prevfloat(fp2,2)
end

#=
@testset "random Double16" begin
    rng = Random.MersenneTwister()
    Random.seed!(rng, 1103)
    T = Float16
    DT = DoubleFloat{T}
    # first make sure we don't throw when sample(T) is 0
    a = rand(rng,DT,2^(precision(T)+2))

    # This takes a few seconds.
    # a = rand(rng,DT,2^(precision(DT)+2))
    # @test_broken count(a .== zero(T)) > 0
end
=#
