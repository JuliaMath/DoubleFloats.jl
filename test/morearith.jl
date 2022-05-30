# more comprehensive tests of corner and extremal cases

FT = Float64; DT = Double{FT}

dnan, fnan = DT(NaN), FT(NaN)
dinf, finf = DT(Inf), FT(Inf)

d0, f0 = zero(DT), zero(FT)
d1, f1 = one(DT), one(FT)

dmin, fmin = floatmin(DT), floatmin(FT)
dmax, fmin = floatmax(DT), floatmax(FT)
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
cbrt_dmax₋, cbrt_fmax₋ = cbrt(dmax₋), cbrt(fmax₋)
sqrt_dmax₋, sqrt_fmax₋ = sqrt(dmax₋), sqrt(fmax₋)
cbrt2_dmin₊, cbrt2_fmin₊ = cbrt_dmin₊^2, cbrt_fmin₊^2 
cbrt2_dmax₋, cbrt2_fmax₋ = cbrt_dmax₋^2, cbrt_fmax₋^2
