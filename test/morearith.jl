# more comprehensive tests of corner and extremal cases

FT = Float64
DT = DoubleFloat{FT}

dnan, fnan = DT(NaN), FT(NaN)
dinf, finf = DT(Inf), FT(Inf)

d0, f0 = zero(DT), zero(FT)
d1, f1 = one(DT), one(FT)

dmin, fmin = floatmin(DT), FT(floatmin(DT))
dmax, fmax = floatmax(DT), FT(floatmax(DT))
dmin₊, fmin₊ = dmin * (1025/1024), fmin * (1025/1024)
dmax₋, fmax₋ = dmax * (1023/1024), fmax * (1023/1024)

sqrt_dmin, sqrt_fmin = sqrt(dmin), sqrt(fmin)
sqrt_dmax, sqrt_fmax = sqrt(dmax), sqrt(fmax)
cbrt_dmin, cbrt_fmin = cbrt(dmin), cbrt(fmin)
cbrt_dmax, cbrt_fmax = cbrt(dmax), cbrt(fmax)
cbrt2_dmin, cbrt2_fmin = cbrt_dmin^2, cbrt_fmin^2
cbrt2_dmax, cbrt2_fmax = cbrt_dmax^2, cbrt_fmax^2

sqrt_dmin₊, sqrt_fmin₊ = sqrt(dmin₊), sqrt(fmin₊)
sqrt_dmax₋, sqrt_fmax₋ = sqrt(dmax₋), sqrt(fmax₋)
cbrt_dmin₊, cbrt_fmin₊ = cbrt(dmin₊), cbrt(fmin₊)
cbrt_dmax₋, cbrt_fmax₋ = cbrt(dmax₋), cbrt(fmax₋)
cbrt2_dmin₊, cbrt2_fmin₊ = cbrt_dmin₊^2, cbrt_fmin₊^2 
cbrt2_dmax₋, cbrt2_fmax₋ = cbrt_dmax₋^2, cbrt_fmax₋^2

dvals = (d0, d1, 
         dmin, dmax, dmin₊, dmax₋, 
         sqrt_dmin, sqrt_dmax, sqrt_dmin₊, sqrt_dmax₋, 
         cbrt_dmin, cbrt_dmax, cbrt_dmin₊, cbrt_dmax₋,
         cbrt2_dmin, cbrt2_dmax, cbrt2_dmin₊, cbrt2_dmax₋,)

fvals = (f0, f1, 
         fmin, fmax, fmin₊, fmax₋, 
         sqrt_fmin, sqrt_fmax, sqrt_fmin₊, sqrt_fmax₋, 
         cbrt_fmin, cbrt_fmax, cbrt_fmin₊, cbrt_fmax₋,
        cbrt2_fmin, cbrt2_fmax, cbrt2_fmin₊, cbrt2_fmax₋,)

dpairs = combinations(dvals, 2)
fpairs = combinations(fvals, 2)

dfvals = zip(dpairs, fpairs)

@testset "more addition" begin
  for (d, f) in dfvals
      @test isapprox(+(d...), +(f...))
  end
end

@testset "more subtraction" begin
  for (d, f) in dfvals
      @test isapprox(-(d...), -(f...))
  end
end

@testset "more multiplication" begin
  for (d, f) in dfvals
      @test isapprox(*(d...), *(f...))
  end
end

@testset "more division" begin
  for (d,f) in dfvals
    if !iszero(d2)
      @test isapprox(/(d...), /(f...))
    end
  end
end
