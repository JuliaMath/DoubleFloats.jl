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

@testset "Trig functions" begin

    x = rand(Double64)
    sinx, cosx = sincos(x)
    @test sinx ≈ sin(x)
    @test cosx ≈ cos(x)
end
