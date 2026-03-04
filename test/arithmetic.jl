@testset "Arithmetic" begin
    x = rand(Complex{Double64})
    y = rand(Double64)

    @test x + y isa Complex{Double64}
    @test y + x isa Complex{Double64}
    @test x - y isa Complex{Double64}
    @test y - x isa Complex{Double64}
    @test x * y isa Complex{Double64}
    @test y * x isa Complex{Double64}
    @test x / y isa Complex{Double64}
    @test y / x isa Complex{Double64}
    @test x ^ y isa Complex{Double64}
    @test y ^ x isa Complex{Double64}
    @test x ^ x isa Complex{Double64}
    @test y ^ y isa Double64

    @test y * y * y ≈ cube(y)
    @test y * y ≈ square(y) == abs2(y)
    @test x * x ≈ square(x)
    @test x * conj(x) ≈ abs2(x)

    x, y = rand(2)
    @test add2(x, y) == (Double64(x) + Double64(y))
    @test sub2(x, y) == (Double64(x) - Double64(y))
    @test mul2(x, y) == (Double64(x) * Double64(y))
    @test div2(x, y) == (Double64(x) / Double64(y))

    @test x ⊕ y == (Double64(x) + Double64(y))
    @test x ⊖ y == (Double64(x) - Double64(y))
    @test x ⊗ y == (Double64(x) * Double64(y))
    @test x ⊘ y == (Double64(x) / Double64(y))
end

@testset "div,rem,.." begin
    a = 17.0
    b =  5.0
    da = Double64(a)
    db = Double64(b)
    
    @test div(da, db) == div(a, b) 
    @test cld(da, db) == cld(a, b) 
    @test fld(da, db) == fld(a, b) 
    @test rem(da, db) == rem(a, b) 
    @test mod(da, db) == mod(a, b) 
    @test divrem(da, db) == divrem(a, b) 
    
    @test fldmod(da, db) == fldmod(a, b) 
end

@testset "Trig functions" begin
    x = randn(Double64)
    sinx, cosx = sincos(x)
    @test sinx ≈ sin(x)
    @test cosx ≈ cos(x)
    sinpix, cospix = sincospi(x)
    @test sinpix ≈ sinpi(x)
    @test cospix ≈ cospi(x)
end

@testset "promotion" begin
    @test df64"123" - df64"123" * df64"0.1" * df64"10.0" == 0.0
    @test df64"123" - 123 * df64"0.1" * df64"10.0" == 0.0
end

@testset "modpi" begin
    @test iszero(DoubleFloats.mod1pi(Double64(pi)))
    @test iszero(DoubleFloats.mod2pi(2*Double64(pi)))
    @test iszero(DoubleFloats.modhalfpi(0.5*Double64(pi)))
    @test iszero(DoubleFloats.modqrtrpi(0.25*Double64(pi)))

    @test iszero(DoubleFloats.mod1pi(Double32(pi)))
    @test iszero(DoubleFloats.mod2pi(2*Double32(pi)))
    @test iszero(DoubleFloats.modhalfpi(0.5*Double32(pi)))
    @test iszero(DoubleFloats.modqrtrpi(0.25*Double32(pi)))

    @test 0 < DoubleFloats.mod1pi(Double64(pi)*10) < eps(Double64(pi)*10)
    @test 0 < DoubleFloats.mod2pi(Double64(pi)*10) < eps(2*Double64(pi)*10)
    @test 0 < DoubleFloats.modhalfpi(Double64(pi)*10) < eps(0.5*Double64(pi)*10)
    @test 0 < DoubleFloats.modqrtrpi(0.25*Double64(pi)*10) < eps(0.25*Double64(pi)*10)

    @test 0 < DoubleFloats.mod1pi(Double32(pi)*10) < eps(Double32(pi)*10)
    @test 0 < DoubleFloats.mod2pi(Double32(pi)*10) < eps(2*Double32(pi)*10)
    @test 0 < DoubleFloats.modhalfpi(Double32(pi)*10) < eps(0.5*Double32(pi)*10)
    @test 0 < DoubleFloats.modqrtrpi(0.25*Double32(pi)*10) < eps(0.25*Double32(pi)*10)
end

@testset "rempi" begin
    @test iszero(DoubleFloats.rem2pi(2*Double64(pi)))
    @test iszero(DoubleFloats.rem2pi(2*Double32(pi)))
end

@testset "hypot" begin
    @test abs(DoubleFloats.hypot(Double64(1), Double64(1))^2 - 2) <= eps(eps(2.0))
    @test abs(sum(DoubleFloats.normalize(Double64(1), Double64(1)))^2 - 2) <= eps(eps(2.0))
end
