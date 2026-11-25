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

# There was a performance regression in version 1.10.0 of DoubleFloats.jl
# where `fma` and `muladd` were allocating memory for some inputs.
# These regression tests ensure that this does not happen again.
_fma_allocation_regression() = fma(Double64(1.0), Double64(1.0), Double64(-1.0))
_muladd_allocation_regression() = muladd(Double64(1.0), Double64(1.0), Double64(-1.0))

@testset "fma/muladd inference and allocations" begin
  @test (@inferred _fma_allocation_regression()) == zero(Double64)
  @test (@inferred _muladd_allocation_regression()) == zero(Double64)
  @test @allocated(_fma_allocation_regression()) == 0
  @test @allocated(_muladd_allocation_regression()) == 0
end

@noinline function _store_fma!(out, op, x, y, z)
    out[] = op(x, y, z)
    return nothing
end

function _test_runtime_fma(op::F, x, y, z) where {F<:Function}
    out = Ref(zero(Double64))
    _store_fma!(out, op, x, y, z)
    @test (@inferred op(x, y, z)) === out[]
    @test (@allocated _store_fma!(out, op, x, y, z)) == 0
    setprecision(BigFloat, 512) do
        reference = BigFloat(x) * BigFloat(y) + BigFloat(z)
        @test !iszero(reference)
        @test abs(BigFloat(out[]) - reference) <= abs(reference) * big"1.5e-30"
    end
end

@testset "FMA refinement with runtime limbs" begin
    x = Double64(1.125, 0x1p-56)
    y = Double64(1.75, -0x1p-55)
    z = -(x * y)
    _test_runtime_fma(fma, x, y, z)
    _test_runtime_fma(muladd, x, y, z)
end
