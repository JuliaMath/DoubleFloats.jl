@testset "construct" begin
   @test Double64(one(Double64)) === one(Double64)
   @test Double64(one(Double32)) === one(Double64)
   @test Double64(one(Double16)) === one(Double64)
   @test Double32(one(Double64)) === one(Double32)
   @test Double32(one(Double32)) === one(Double32)
   @test Double32(one(Double16)) === one(Double32)
   @test Double16(one(Double64)) === one(Double16)
   @test Double16(one(Double32)) === one(Double16)
   @test Double16(one(Double16)) === one(Double16)
   
   @test DoubleFloat(one(Double64)) === one(Double64)
   @test DoubleFloat(one(Double32)) === one(Double64)
   @test DoubleFloat(one(Double16)) === one(Double64)
   
   @test DoubleFloat(1.0) === one(Double64)
   @test DoubleFloat(1.0f0) === one(Double32)
   @test DoubleFloat(Float16(1.0)) === one(Double16)
   
   @test ComplexD64(1, 1) === ComplexD64(1.0, 1.0)
   @test ComplexD32(1, 1) === ComplexD32(1.0f0, 1.0f0)
   @test ComplexD16(1, 1) === ComplexD16(Float16(1.0), Float16(1.0))  
end
