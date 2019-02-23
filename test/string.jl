@testset "string" begin

  @test string(Double64(pi)) == "3.1415926535897932384626433832795058"
  @test string(Double32(pi)) == "3.141592653589796"
  @test string(Double16(pi)) == "3.1415925"

  @test string(Double64("1.0e-2")) == "1.0000000000000000000000000000000007e-02"
  @test string(Double32("1.0e-4")) == "1.000000000000000e-04"
  @test string(Double16("1.0e-4")) == "1.0001659e-04"
  
  @test string(ComplexD64(1.0,1.0)) == "1.0 + 1.0im"
  @test string(ComplexD32(1.0,1.0)) == "1.0 + 1.0im"
  @test string(ComplexD16(1.0,1.0)) == "1.0 + 1.0im"

  @test stringtyped(Double64(pi)) == "Double64(3.141592653589793, 1.2246467991473532e-16)"
  @test stringtyped(Double32(pi)) == "Double32(3.1415927, -8.742278e-8)"
  @test stringtyped(Double16(pi)) == "Double16(3.14, 0.0009675)"

  @test stringtyped(ComplexD64(1.0,1.0)) == "ComplexD64(Double64(1.0, 0.0), Double64(1.0, 0.0))"
  @test stringtyped(ComplexD32(1.0,1.0)) == "ComplexD32(Double32(1.0, 0.0), Double32(1.0, 0.0))"
  @test stringtyped(ComplexD16(1.0,1.0)) == "ComplexD16(Double16(1.0, 0.0), Double16(1.0, 0.0))"
  
end
