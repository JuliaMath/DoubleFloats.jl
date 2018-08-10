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
end

