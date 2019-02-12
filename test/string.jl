@testset "string" begin

  @test string(Double64(pi)) == "3.1415926535897932384626433832795058"
  @test string(Double32(pi)) == "3.141592653589796"
  @test string(Double16(pi)) == "3.1415925"

  @test stringtyped(Double64(pi)) == "Double64(3.141592653589793, 1.2246467991473532e-16)"
  @test stringtyped(Double32(pi)) == "Double32(3.1415927, -8.742278e-8)"
  @test stringtyped(Double16(pi)) == "Double16(3.14, 0.0009675)"

end
