@testset "fma" begin

  @test HILO(fma(Float64(pi), Float64(phi), Double64(gamma))) == (5.660419357216792, 4.1344240638440936e-16)
  @test HILO(fma(Float64(pi), Double64(phi), Float64(gamma))) == (5.660419357216792, 2.477303893634162e-16)
  @test HILO(fma(Double64(pi), Float64(phi), Float64(gamma))) == (5.660419357216793, -2.7164108363986695e-16)
  @test HILO(fma(Double64(pi), Double64(phi), Float64(gamma))) == (5.660419357216793, -4.422960158132908e-16)
  @test HILO(fma(Double64(pi), Float64(phi), Double64(gamma))) == (5.660419357216793, -2.765839987922976e-16)
  @test HILO(fma(Double64(pi), Double64(phi), Double64(gamma))) == (5.660419357216792, 4.4093948873440384e-16)

  @test HILO(muladd(Float64(pi), Float64(phi), Double64(gamma))) == (5.660419357216792, 4.1344240638440936e-16)
  @test HILO(muladd(Float64(pi), Double64(phi), Float64(gamma))) == (5.660419357216792, 2.477303893634162e-16)
  @test HILO(muladd(Double64(pi), Float64(phi), Float64(gamma))) == (5.660419357216793, -2.7164108363986695e-16)
  @test HILO(muladd(Double64(pi), Double64(phi), Float64(gamma))) == (5.660419357216793, -4.422960158132908e-16)
  @test HILO(muladd(Double64(pi), Float64(phi), Double64(gamma))) == (5.660419357216793, -2.765839987922976e-16)
  @test HILO(muladd(Double64(pi), Double64(phi), Double64(gamma))) == (5.660419357216792, 4.4093948873440384e-16)

end
