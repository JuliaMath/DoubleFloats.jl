function test_string_and_show(x, s)
  b = IOBuffer()
  show(b, x)
  @test String(take!(b)) == string(x) == s
end

@testset "string" begin
  test_string_and_show(Double64(pi), "3.14159265358979323846264338327950588")

  x = Double64(2.3045377697175683e-24, -1.5436846311151439e-40)
  test_string_and_show(x, "2.30453776971756809999999999999975586e-24")
  
  test_string_and_show(ComplexDF64(1.0,1.0), "1.0 + 1.0im")

  x = Complex{Double64}(pi)+Double64(pi)*im
  test_string_and_show(x, "3.14159265358979323846264338327950588 + 3.14159265358979323846264338327950588im")

  @test stringtyped(Double64(pi)) == "Double64(3.141592653589793, 1.2246467991473532e-16)"

  @test stringtyped(ComplexDF64(1.0,1.0)) == "ComplexDF64(Double64(1.0, 0.0), Double64(1.0, 0.0))"
  
end
