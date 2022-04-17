@testset "string" begin

  @test string(Double64(pi)) == "3.14159265358979323846264338327950588"

  @test string(Double64(2.3045377697175683e-24, -1.5436846311151439e-40)) == "2.30453776971756809999999999999975586e-24"
  
  @test string(ComplexDF64(1.0,1.0)) == "1.0 + 1.0im"

  @test stringtyped(Double64(pi)) == "Double64(3.141592653589793, 1.2246467991473532e-16)"

  @test stringtyped(ComplexDF64(1.0,1.0)) == "ComplexDF64(Double64(1.0, 0.0), Double64(1.0, 0.0))"
  
end
