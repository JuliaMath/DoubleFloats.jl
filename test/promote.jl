@testset "promote" begin
  @test typeof(promote(one(Double64), one(Double32))[1]) === Double64
  @test typeof(promote(one(Double64), one(Double16))[1]) === Double64
  @test typeof(promote(one(Double32), one(Double16))[1]) === Double32  
  
  @test typeof(promote(one(Double64), one(BigInt))[1]) === BigInt
  @test typeof(promote(one(Double32), one(BigInt))[1]) === BigInt
  @test typeof(promote(one(Double16), one(BigInt))[1]) === BigInt
  
  @test typeof(promote(one(Double64), one(BigFloat))[1]) === BigFloat
  @test typeof(promote(one(Double32), one(BigFloat))[1]) === BigFloat
  @test typeof(promote(one(Double16), one(BigFloat))[1]) === BigFloat

  @test promote_type(Double64, Double32) === Double64
  @test promote_type(Double64, Double16) === Double64
  @test promote_type(Double32, Double16) === Double32
end  
