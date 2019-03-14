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
   
   @test Double64(one(Float64)) === one(Double64)
   @test Double64(one(Float32)) === one(Double64)
   @test Double64(one(Float16)) === one(Double64)
   @test Double32(one(Float64)) === one(Double32)
   @test Double32(one(Float32)) === one(Double32)
   @test Double32(one(Float16)) === one(Double32)
   @test Double16(one(Float64)) === one(Double16)
   @test Double16(one(Float32)) === one(Double16)
   @test Double16(one(Float16)) === one(Double16)

   @test DoubleFloat(one(Double64)) === one(Double64)
   @test DoubleFloat(one(Double32)) === one(Double32)
   @test DoubleFloat(one(Double16)) === one(Double16)
   
   @test DoubleFloat(1.0) === one(Double64)
   @test DoubleFloat(1.0f0) === one(Double32)
   @test DoubleFloat(Float16(1.0)) === one(Double16)
   
   @test ComplexDF64(1, 1) === ComplexDF64(1.0, 1.0)
   @test ComplexDF32(1, 1) === ComplexDF32(1.0f0, 1.0f0)
   @test ComplexDF16(1, 1) === ComplexDF16(Float16(1.0), Float16(1.0))  
   @test ComplexDF64(1//1, -1//1) === ComplexDF64(1.0, -1.0)
   @test ComplexDF32(1//1, -1//1) === ComplexDF32(1.0f0, -1.0f0)
   @test ComplexDF16(1//1, -1//1) === ComplexDF16(Float16(1.0), -Float16(1.0))  
end

@testset "intraconstruct" begin
   @test Double64(Double32(1)) === Double64(1)
   @test Double64(Double16(1)) === Double64(1)
   @test Double32(Double16(1)) === Double32(1)

   @test Double64(1.0) === Double64(1)
   @test Double64(1.0f0) === Double64(1)
   @test Double64(Float16(1.0)) === Double64(1)

   @test Double32(1.0) === Double32(1)
   @test Double32(1.0f0) === Double32(1)
   @test Double32(Float16(1.0)) === Double32(1)

   @test Double16(1.0) == Double16(1)
   @test Double16(1.0f0) == Double16(1)
   @test Double16(Float16(1.0)) == Double16(1)

   @test Double64(Int64(1)) === Double64(1.0)
   @test Double32(Int64(1)) === Double32(1.0)
   @test Double16(Int64(1)) === Double16(1.0)
   
   @test Double64(Int32(1)) === Double64(1.0)
   @test Double32(Int32(1)) === Double32(1.0)
   @test Double16(Int32(1)) === Double16(1.0)

   @test Double64(Int16(1)) === Double64(1.0)
   @test Double32(Int16(1)) === Double32(1.0)
   @test Double16(Int16(1)) === Double16(1.0)
end
