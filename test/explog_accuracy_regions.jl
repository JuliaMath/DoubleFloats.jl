# Diagnostic (not run as part of runtests.jl): scans exp/log over many regions of the
# Double64 domain, comparing against BigFloat, to locate where accuracy degrades below
# the ~2^-104 (double-double) relative-precision floor.
#
# Run from the package root with:
#   julia --project=. test/explog_accuracy_regions.jl

import Pkg
Pkg.activate(joinpath(@__DIR__, ".."))

using DoubleFloats
using Random

setprecision(BigFloat, 512)

# relative error in ulps of Double64 (2^-104 eps-ish; use 2^-106 as "1 ulp" of double-double)
const EPS_DD = big"2.0"^-104

function relerr(dd::Double64, big_ref::BigFloat)
    ddbig = BigFloat(dd)
    if iszero(big_ref)
        return Float64(abs(ddbig - big_ref))
    end
    return Float64(abs(ddbig - big_ref) / abs(big_ref))
end

function scan(label, xs, f_dd, f_big; ulp_thresh=100.0)
    worst = 0.0
    worst_x = 0.0
    nbad = 0
    for x in xs
        xdd = Double64(x)
        try
            r_dd = f_dd(xdd)
            r_big = f_big(BigFloat(xdd))
            (isnan(r_dd) || isinf(r_dd)) && continue
            re = relerr(r_dd, r_big)
            ulps = re / Float64(EPS_DD)
            if ulps > worst
                worst = ulps
                worst_x = x
            end
            if ulps > ulp_thresh
                nbad += 1
            end
        catch e
            println("  ERROR at x=$x: $e")
        end
    end
    println("$label : worst = $(worst) ulps at x=$(worst_x)  (n_bad>$(ulp_thresh)ulp = $nbad / $(length(xs)))")
    return worst, worst_x
end

Random.seed!(42)

println("=== EXP regions ===")

# 1. near zero (various tiny magnitudes)
xs_near0 = [10.0^(-k) for k in 1:18]
xs_near0 = vcat(xs_near0, -xs_near0)
scan("exp near 0 (powers of 10)", xs_near0, exp, exp)

# 2. random tiny
xs_tiny_rand = (rand(2000) .- 0.5) .* 2.0 .^ (-collect(range(1,60,length=2000)))
scan("exp tiny random", xs_tiny_rand, exp, exp)

# 3. near half-integers / integer boundaries in [0,64] (calc_exp uses xint, xfrac with 0.5 branch)
xs_intbound = Float64[]
for k in 0:64
    push!(xs_intbound, k + 0.5)
    push!(xs_intbound, k + 0.5 - 1e-14)
    push!(xs_intbound, k + 0.5 + 1e-14)
    push!(xs_intbound, Float64(k))
    push!(xs_intbound, k - 1e-14)
    push!(xs_intbound, k + 1e-14)
end
scan("exp near integer/half-integer boundaries [0,64]", xs_intbound, exp, exp)

# 4. random over full safe domain (-708,708)
xs_full = (rand(3000) .- 0.5) .* 1400.0
scan("exp full domain random", xs_full, exp, exp)

# 5. near overflow/underflow boundary (709, -709)
xs_bound = vcat(700:0.5:709, -709:0.5:-700)
scan("exp near +-709 boundary", collect(xs_bound), exp, exp)

# 6. large multiples of 64 (dv path in calc_exp)
xs_large64 = Float64[64*k + r for k in 1:11 for r in (0.0, 0.3, 0.7, 31.5, 63.9)]
xs_large64 = filter(x -> abs(x) < 709, xs_large64)
scan("exp large args exercising dv>1 path", xs_large64, exp, exp)

println()
println("=== LOG regions ===")

# 1. near x=1 (classic log1p-loss-of-precision region)
xs_near1 = Float64[]
for k in 1:16
    d = 10.0^(-k)
    push!(xs_near1, 1+d, 1-d)
end
scan("log near x=1 (relative)", xs_near1, log, log)

# 2. very close to 1 using Double64 lo-part perturbations (below Float64 ulp of 1.0)
xs_near1_dd = Double64[]
for k in 1:20
    push!(xs_near1_dd, Double64(1.0, 10.0^(-k)))
    push!(xs_near1_dd, Double64(1.0, -10.0^(-k)))
end
let worst = 0.0, worst_x = xs_near1_dd[1]
    for xdd in xs_near1_dd
        r_dd = log(xdd)
        r_big = log(BigFloat(xdd))
        isnan(r_dd) && continue
        re = relerr(r_dd, r_big)
        ulps = re / Float64(EPS_DD)
        if ulps > worst
            worst = ulps; worst_x = xdd
        end
    end
    println("log near x=1 (Double64(1.0, tiny lo)) : worst = $worst ulps at x=$worst_x")
end

# 3. random small magnitude args (near 0, x -> 0+)
xs_smallpos = [10.0^(-k) for k in 1:300]
scan("log near 0+ (powers of 10 down to 1e-300)", xs_smallpos, log, log)

# 4. random large magnitude
xs_large = [10.0^k for k in 1:300]
scan("log large args (powers of 10 up to 1e300)", xs_large, log, log)

# 5. random full positive domain
xs_fullpos = rand(3000) .* 1000.0 .+ 1e-10
scan("log full positive domain random", xs_fullpos, log, log)

# 6. random near 1 with random signs/magnitudes of perturbation (both hi and lo)
xs_near1b = Float64[]
for _ in 1:2000
    push!(xs_near1b, 1 + (rand()-0.5)*2.0^(-rand(20:52)))
end
scan("log near 1 random perturbations at various double ulp scales", xs_near1b, log, log)

println()
println("=== Follow-up: characterize exp large-negative-arg region ===")
for x in [-650.0, -680.0, -690.0, -695.0, -699.0, -699.3263934463292, -700.0, -703.0, -705.0, -707.0, -708.0, -708.9, -708.99]
    xdd = Double64(x)
    r_dd = exp(xdd)
    r_big = exp(BigFloat(xdd))
    re = relerr(r_dd, r_big)
    ulps = re / Float64(EPS_DD)
    println("  x=$x  relerr=$(re)  ulps=$(ulps)")
end

println()
println("=== Follow-up: characterize log near x=1 region ===")
for k in 0:20
    d = 2.0^(-k)
    x = 1 + d
    xdd = Double64(x)
    r_dd = log(xdd)
    r_big = log(BigFloat(xdd))
    re = relerr(r_dd, r_big)
    ulps = re / Float64(EPS_DD)
    println("  x=1+2^-$k=$x  relerr=$(re)  ulps=$(ulps)")
end
println()
for k in 0:20
    d = 2.0^(-k)
    x = 1 - d
    xdd = Double64(x)
    r_dd = log(xdd)
    r_big = log(BigFloat(xdd))
    re = relerr(r_dd, r_big)
    ulps = re / Float64(EPS_DD)
    println("  x=1-2^-$k=$x  relerr=$(re)  ulps=$(ulps)")
end
