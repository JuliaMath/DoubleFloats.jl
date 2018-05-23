
setprecision(BigFloat, 512)
srand(1602);
const nrands = 1_000 # tested with nrands = 1_000

rand_vals = rand(Double, nrands);
rand_bigf = BigFloat.(rand_vals);

rand1_vals = rand_vals .+ 1.0;
rand1_bigf = BigFloat.(rand1_vals);

rand20_vals = rand_vals .* 20.0;
rand20_bigf = BigFloat.(rand20_vals);

function test_atol(bigf, rnds, fn, tol)
    T = eltype(rnds)
    fn_bigf = map(x->T(fn(x)), bigf)
    fn_rnds = map(fn, rnds)
    return all(isapprox.(fn_bigf, fn_rnds, atol=tol))
end
function test_rtol(bigf, rnds, fn, tol)
    T = eltype(rnds)
    fn_bigf = map(x->T(fn(x)), bigf)
    fn_rnds = map(fn, rnds)
    return all(isapprox.(fn_bigf, fn_rnds, rtol=tol))
end
  
@test test_atol(rand_bigf, rand_vals, exp, 1.0e-29)
@test test_rtol(rand_bigf, rand_vals, exp, 1.5e-31)

@test test_atol(rand_bigf, rand_vals, log, 1.0e-29)
@test test_rtol(rand_bigf, rand_vals, log, 1.5e-29)

@test test_atol(rand_bigf, rand_vals, sin, 1.0e-29)
@test test_rtol(rand_bigf, rand_vals, sin, 1.0e-30)

@test test_atol(rand_bigf, rand_vals, cos, 1.0e-29)
@test test_rtol(rand_bigf, rand_vals, cos, 1.0e-30)

@test test_atol(rand_bigf, rand_vals, tan, 1.0e-29)
@test test_rtol(rand_bigf, rand_vals, tan, 1.0e-30)

@test test_atol(rand_bigf, rand_vals, asin, 1.0e-29)
@test test_rtol(rand_bigf, rand_vals, asin, 1.0e-29)

@test test_atol(rand_bigf, rand_vals, acos, 1.0e-29)
@test test_rtol(rand_bigf, rand_vals, acos, 1.0e-29)

@test test_atol(rand_bigf, rand_vals, atan, 1.0e-29)
@test test_rtol(rand_bigf, rand_vals, atan, 1.0e-29)

@test test_atol(rand_bigf, rand_vals, sinh, 1.0e-29)
@test test_rtol(rand_bigf, rand_vals, sinh, 1.0e-28)

@test test_atol(rand_bigf, rand_vals, cosh, 1.0e-29)
@test test_rtol(rand_bigf, rand_vals, cosh, 1.0e-28)

@test test_atol(rand_bigf, rand_vals, tanh, 1.0e-29)
@test test_rtol(rand_bigf, rand_vals, tanh, 1.0e-28)

@test test_atol(rand_bigf, rand_vals, asinh, 1.0e-29)
@test test_rtol(rand_bigf, rand_vals, asinh, 1.0e-27)

@test test_atol(rand1_bigf, rand1_vals, acosh, 1.0e-29)
@test test_rtol(rand1_bigf, rand1_vals, acosh, 1.0e-27)

@test test_atol(rand_bigf, rand_vals, atanh, 1.0e-29)
@test test_rtol(rand_bigf, rand_vals, atanh, 1.0e-27)

  
@test test_atol(rand20_bigf, rand20_vals, exp, 1.0e-29)
@test test_rtol(rand20_bigf, rand20_vals, exp, 1.5e-31)

@test test_atol(rand20_bigf, rand20_vals, log, 1.0e-29)
@test test_rtol(rand20_bigf, rand20_vals, log, 1.5e-29)

@test test_atol(rand20_bigf, rand20_vals, sin, 1.0e-26)
@test test_rtol(rand20_bigf, rand20_vals, sin, 1.0e-27)

@test test_atol(rand20_bigf, rand20_vals, cos, 1.0e-26)
@test test_rtol(rand20_bigf, rand20_vals, cos, 1.0e-27)

@test test_atol(rand20_bigf, rand20_vals, tan, 1.0e-24)
@test test_rtol(rand20_bigf, rand20_vals, tan, 1.0e-27)

rand_vals = -rand_vals;
rand_bigf = BigFloat.(rand_vals);

rand1_vals = -rand1_vals;
rand1_bigf = BigFloat.(rand1_vals);

rand20_vals = -rand1_vals;
rand20_bigf = BigFloat.(rand20_vals);

@test test_atol(rand_bigf, rand_vals, exp, 1.0e-29)
@test test_rtol(rand_bigf, rand_vals, exp, 1.5e-31)

@test test_atol(rand_bigf, rand_vals, sin, 1.0e-29)
@test test_rtol(rand_bigf, rand_vals, sin, 1.0e-30)

@test test_atol(rand_bigf, rand_vals, cos, 1.0e-29)
@test test_rtol(rand_bigf, rand_vals, cos, 1.0e-30)

@test test_atol(rand_bigf, rand_vals, tan, 1.0e-29)
@test test_rtol(rand_bigf, rand_vals, tan, 1.0e-30)

@test test_atol(rand_bigf, rand_vals, asin, 1.0e-29)
@test test_rtol(rand_bigf, rand_vals, asin, 1.0e-29)

@test test_atol(rand_bigf, rand_vals, acos, 1.0e-29)
@test test_rtol(rand_bigf, rand_vals, acos, 1.0e-29)

@test test_atol(rand_bigf, rand_vals, atan, 1.0e-29)
@test test_rtol(rand_bigf, rand_vals, atan, 1.0e-29)

@test test_atol(rand_bigf, rand_vals, sinh, 1.0e-29)
@test test_rtol(rand_bigf, rand_vals, sinh, 1.0e-28)

@test test_atol(rand_bigf, rand_vals, cosh, 1.0e-29)
@test test_rtol(rand_bigf, rand_vals, cosh, 1.0e-28)

@test test_atol(rand_bigf, rand_vals, tanh, 1.0e-29)
@test test_rtol(rand_bigf, rand_vals, tanh, 1.0e-28)

@test test_atol(rand_bigf, rand_vals, asinh, 1.0e-29)
@test test_rtol(rand_bigf, rand_vals, asinh, 1.0e-27)

@test test_atol(rand_bigf, rand_vals, atanh, 1.0e-29)
@test test_rtol(rand_bigf, rand_vals, atanh, 1.0e-27)

  
@test test_atol(rand20_bigf, rand20_vals, exp, 1.0e-29)
@test test_rtol(rand20_bigf, rand20_vals, exp, 1.5e-31)

@test test_atol(rand20_bigf, rand20_vals, sin, 1.0e-26)
@test test_rtol(rand20_bigf, rand20_vals, sin, 1.0e-27)

@test test_atol(rand20_bigf, rand20_vals, cos, 1.0e-26)
@test test_rtol(rand20_bigf, rand20_vals, cos, 1.0e-27)

@test test_atol(rand20_bigf, rand20_vals, tan, 1.0e-24)
@test test_rtol(rand20_bigf, rand20_vals, tan, 1.0e-27)
