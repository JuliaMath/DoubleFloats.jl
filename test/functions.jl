@testset "Exponential functions"  begin
    @test Double64(10.0)^0 == Double64(1.0)
    @test Double64(10.0)^1 == Double64(10.0)
    @test_throws DomainError Double64(0.0)^0
end
