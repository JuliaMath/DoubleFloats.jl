# more comprehensive tests of corner and extremal cases

FT = Float64
DT = DoubleFloat{FT}

dnan, fnan = DT(NaN), FT(NaN)
dinf, finf = DT(Inf), FT(Inf)

d0, f0 = zero(DT), zero(FT)
d1, f1 = one(DT), one(FT)

dmin, fmin = floatmin(DT), floatmin(FT)
dmax, fmax = floatmax(DT), floatmax(FT)
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
cbrt_dmax₋, sqrt_fmax₋ = sqrt(dmax₋), sqrt(fmax₋)
cbrt2_dmin₊, cbrt2_fmin₊ = cbrt_dmin₊^2, cbrt_fmin₊^2 
cbrt2_dmax₋, cbrt2_fmax₋ = cbrt_dmax₋^2, cbrt_fmax₋^2

dvals = (dnan, dinf, d0, d1, dmin, dmax, dmin₊, dmax₋, sqrt_dmin, sqrt_dmax, sqrt_dmin₊, sqrt_dmax₋, 
         cbrt_dmin, cbrt_dmax, cbrt_dmin₊, cbrt_dmax₋, cbrt2_dmin, cbrt2_dmax, cbrt2_dmin₊, cbrt2_dmax₋,)
fvals = (fnan, finf, f0, f1, dmin, fmax, fmin₊, fmax₋, sqrt_fmin, sqrt_fmax, sqrt_fmin₊, sqrt_fmax₋, 
         cbrt_fmin, cbrt_fmax, cbrt_fmin₊, cbrt_fmax₋, cbrt2_fmin, cbrt2_fmax, cbrt2_fmin₊, cbrt2_fmax₋,)

dfvals = zip(dvals, fvals)

@testset "more addition" begin
  for (d1,f1) in dfvals
    for (d2, f2) in dfvals
      @test isapprox(d1+d2, f1+f2)
    end
  end
end

@testset "more subtraction" begin
  for (d1,f1) in dfvals
    for (d2, f2) in dfvals
      @test isapprox(d1-d2, f1-f2)
    end
  end
end

@testset "more multiplication" begin
  for (d1,f1) in dfvals
    for (d2, f2) in dfvals
      @test isapprox(d1*d2, f1*f2)
    end
  end
end

@testset "more division" begin
  for (d1,f1) in dfvals
    for (d2, f2) in dfvals
      if !iszero(d2)
          @test isapprox(d1/d2, f1/f2)
      end  
    end
  end
end

end
