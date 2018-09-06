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

    x = rand(Double64)
    sinx, cosx = sincos(x)
    @test sinx ≈ sin(x)
    @test cosx ≈ cos(x)
end

@testset "promotion" begin
    @test d64"123" - d64"123" * d64"0.1" * d64"10.0" == 0.0
    @test d64"123" - 123 * d64"0.1" * d64"10.0" == 0.0
end
