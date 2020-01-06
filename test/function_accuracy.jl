setprecision(Base.BigFloat, 512)
Random.seed!(1602);
const nrands = 1_000 # tested with nrands = 1_000

function excise_nans_infs(v1::Vector{T1}, v2::Vector{T2}) where {T1<:AbstractFloat, T2<:AbstractFloat}
    n1 = length(v1)
    n2 = length(v2)
    n1 == n2 || throw(ErrorException("vectors must be of the same length"))
    ns1 = collect(1:n1)
    ns2 = copy(ns1)
    keep1 = ns1[map(isfinite, v1)]
    keep2 = ns2[map(isfinite, v2)]
    keep = intersect(keep1, keep2)
    return v1[ keep ], v2[ keep ]
end


function test_atol(big_rands, dbl_rands, fn, tol)
    T = eltype(dbl_rands)
    fn_big_rands = map(fn, big_rands)
    fn_dbl_rands = map(fn, dbl_rands)
    fn_big_rands, fn_dbl_rands = excise_nans_infs(fn_big_rands, fn_dbl_rands)
    fn_dblbig_rands = map(T, fn_big_rands)
    fn_diff = map(abs, fn_dblbig_rands .- fn_dbl_rands)
    fn_res  = maximum(fn_diff) <= tol
    return fn_res
end

function test_rtol(big_rands, dbl_rands, fn, tol)
    T = eltype(dbl_rands)
    fn_big_rands = map(fn, big_rands)
    fn_dbl_rands = map(fn, dbl_rands)
    fn_big_rands, fn_dbl_rands = excise_nans_infs(fn_big_rands, fn_dbl_rands)
    fn_dblbig_rands = map(T, fn_big_rands)
    fn_diff = map(abs, fn_dblbig_rands .- fn_dbl_rands)
    fn_reldiff = fn_diff ./ fn_dblbig_rands
    fn_res  = maximum(fn_reldiff) <= tol
    return fn_res
end

@testset "Function Accuracy" begin

    rand_vals = rand(Double64, nrands);
    rand_bigf = Base.BigFloat.(rand_vals);

    rand1_vals = rand_vals .+ 1.0;
    rand1_bigf = Base.BigFloat.(rand1_vals);
    
    @test test_atol(rand_bigf, rand_vals, exp, 1.0e-31)
    @test test_rtol(rand_bigf, rand_vals, exp, 1.0e-31)

    @test test_atol(rand_bigf, rand_vals, log, 1.0e-31)
    @test test_rtol(rand_bigf, rand_vals, log, 1.0e-31)

    @test test_atol(rand_bigf, rand_vals, sin, 1.0e-31)
    @test test_rtol(rand_bigf, rand_vals, sin, 1.0e-31)

    @test test_atol(rand_bigf, rand_vals, cos, 1.0e-31)
    @test test_rtol(rand_bigf, rand_vals, cos, 1.0e-31)

    @test test_atol(rand_bigf, rand_vals, tan, 1.0e-31)
    @test test_rtol(rand_bigf, rand_vals, tan, 1.0e-31)

    @test test_atol(rand_bigf, rand_vals, asin, 1.0e-31)
    @test test_rtol(rand_bigf, rand_vals, asin, 1.0e-31)

    @test test_atol(rand_bigf, rand_vals, acos, 1.0e-31)
    @test test_rtol(rand_bigf, rand_vals, acos, 1.0e-31)

    @test test_atol(rand_bigf, rand_vals, atan, 1.0e-31)
    @test test_rtol(rand_bigf, rand_vals, atan, 1.0e-31)

    @test test_atol(rand_bigf, rand_vals, sinh, 1.0e-31)
    @test test_rtol(rand_bigf, rand_vals, sinh, 1.0e-29)

    @test test_atol(rand_bigf, rand_vals, cosh, 1.0e-31)
    @test test_rtol(rand_bigf, rand_vals, cosh, 1.0e-31)

    @test test_atol(rand_bigf, rand_vals, tanh, 1.0e-31)
    @test test_rtol(rand_bigf, rand_vals, tanh, 1.0e-29)

    @test test_atol(rand_bigf, rand_vals, asinh, 1.0e-31)
    @test test_rtol(rand_bigf, rand_vals, asinh, 1.0e-29)

    @test test_atol(rand_bigf, rand_vals, atanh, 1.0e-31)
    @test test_rtol(rand_bigf, rand_vals, atanh, 1.0e-30)


    @test test_atol(rand1_bigf, rand1_vals, exp, 1.0e-30)
    @test test_rtol(rand1_bigf, rand1_vals, exp, 1.0e-31)
    
    @test test_atol(rand1_bigf, rand1_vals, log, 1.0e-31)
    @test test_rtol(rand1_bigf, rand1_vals, log, 1.0e-31)

    @test test_atol(rand1_bigf, rand1_vals, sin, 1.0e-31)
    @test test_rtol(rand1_bigf, rand1_vals, sin, 1.0e-31)

    @test test_atol(rand1_bigf, rand1_vals, cos, 1.0e-31)
    @test test_rtol(rand1_bigf, rand1_vals, cos, 1.0e-28)

    @test test_atol(rand1_bigf, rand1_vals, tan, 1.0e-30)
    @test test_rtol(rand1_bigf, rand1_vals, tan, 1.0e-30)

    @test test_atol(rand1_bigf, rand1_vals, atan, 1.0e-31)
    @test test_rtol(rand1_bigf, rand1_vals, atan, 1.0e-31)

    @test test_atol(rand1_bigf, rand1_vals, sinh, 1.0e-30)
    @test test_rtol(rand1_bigf, rand1_vals, sinh, 1.0e-31)

    @test test_atol(rand1_bigf, rand1_vals, cosh, 1.0e-30)
    @test test_rtol(rand1_bigf, rand1_vals, cosh, 1.0e-31)

    @test test_atol(rand1_bigf, rand1_vals, tanh, 1.0e-31)
    @test test_rtol(rand1_bigf, rand1_vals, tanh, 1.0e-31)

    @test test_atol(rand1_bigf, rand1_vals, asinh, 1.0e-31)
    @test test_rtol(rand1_bigf, rand1_vals, asinh, 1.0e-31)
end
