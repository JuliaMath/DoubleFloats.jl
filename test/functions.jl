@testset "Strings" begin
    @test LO(sqrt(d64"2")) < LO(nextfloat(sqrt(d64"2")))
end

@testset "Adjacent values" begin
    @test nextfloat(Double64(10))  > Double64(10)
    @test nextfloat(Double32(-10)) > Double32(-10)
    @test prevfloat(Double64(10))  < Double64(10)
    @test prevfloat(Double32(-10)) < Double32(-10)    
    @test nextfloat(Double64(10),3)  > nextfloat(Double64(10),2)
    @test nextfloat(Double32(-10),3) > nextfloat(Double32(-10),2)
    @test prevfloat(Double64(10),3)  < prevfloat(Double64(10),2)
    @test prevfloat(Double32(-10),3) < prevfloat(Double32(-10),2)
end

@testset "power functions"  begin
    @test Double64(10.0)^0 == Double64(1.0)
    @test Double64(10.0)^1 == Double64(10.0)
    @test_throws DomainError Double64(0.0)^0
end
