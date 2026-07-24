@testset "fma" begin

  @test HILO(fma(Float64(pi), Float64(phi), Double64(eulergamma))) == (5.660419357216792, 4.1344240638440936e-16)
  @test HILO(fma(Float64(pi), Double64(phi), Float64(eulergamma))) == (5.660419357216792, 2.477303893634162e-16)
  @test HILO(fma(Double64(pi), Float64(phi), Float64(eulergamma))) == (5.660419357216793, -2.7164108363986695e-16)
  @test HILO(fma(Double64(pi), Double64(phi), Float64(eulergamma))) == (5.660419357216793, -4.422960158132908e-16)
  @test HILO(fma(Double64(pi), Float64(phi), Double64(eulergamma))) == (5.660419357216793, -2.765839987922976e-16)
  @test HILO(fma(Double64(pi), Double64(phi), Double64(eulergamma))) == (5.660419357216792, 4.4093948873440384e-16)

  @test HILO(muladd(Float64(pi), Float64(phi), Double64(eulergamma))) == (5.660419357216792, 4.1344240638440936e-16)
  @test HILO(muladd(Float64(pi), Double64(phi), Float64(eulergamma))) == (5.660419357216792, 2.477303893634162e-16)
  @test HILO(muladd(Double64(pi), Float64(phi), Float64(eulergamma))) == (5.660419357216793, -2.7164108363986695e-16)
  @test HILO(muladd(Double64(pi), Double64(phi), Float64(eulergamma))) == (5.660419357216793, -4.422960158132908e-16)
  @test HILO(muladd(Double64(pi), Float64(phi), Double64(eulergamma))) == (5.660419357216793, -2.765839987922976e-16)
  @test HILO(muladd(Double64(pi), Double64(phi), Double64(eulergamma))) == (5.660419357216792, 4.4093948873440384e-16)

end

@testset "fma adversarial cancellation accuracy" begin
  setprecision(BigFloat, 512) do
    rng = Random.MersenneTwister(0x3109)
    bigdf(x::Double64) = BigFloat(HI(x)) + BigFloat(LO(x))

    # Full Double64 inputs, low-word perturbations, and cancellation depths
    # through 120 bits.  The refinement path should retain double-double
    # relative accuracy whenever the exact result is nonzero.
    for exponent in (-100, 0, 100), depth in 0:8:120, _ in 1:2
      scale = 2.0^exponent
      ahi = (2rand(rng) - 1) * sqrt(scale)
      bhi = (2rand(rng) - 1) * sqrt(scale)
      a = Double64(ahi, (2rand(rng) - 1) * eps(ahi))
      b = Double64(bhi, (2rand(rng) - 1) * eps(bhi))
      c = -(a * b) + Double64((rand(rng, Bool) ? 1.0 : -1.0) * scale * 2.0^-depth)

      exact = bigdf(a) * bigdf(b) + bigdf(c)
      iszero(exact) && continue
      relative_error = abs(bigdf(fma(a, b, c)) - exact) / abs(exact)
      @test relative_error < big"1.5e-30"
    end
  end
end
