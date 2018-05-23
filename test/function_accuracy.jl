
setprecision(BigFloat, 512)
srand(1602);
const nrands = 1_000 # tested with nrands = 1_000

rand_accu = rand(Double, nrands);
rand_bigf = BigFloat.(rand_accu);

rand1_accu = rand_accu .+ 1.0;
rand1_bigf = BigFloat.(rand1_accu);

rand20_accu = rand_accu .* 20.0;
rand20_bigf = BigFloat.(rand20_accu);

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
  
@test test_atol(rand_bigf, rand_accu, exp, 1.0e-29)
@test test_rtol(rand_bigf, rand_accu, exp, 1.5e-31)

@test test_atol(rand_bigf, rand_accu, log, 1.0e-29)
@test test_rtol(rand_bigf, rand_accu, log, 1.5e-29)

@test test_atol(rand_bigf, rand_accu, sin, 1.0e-29)
@test test_rtol(rand_bigf, rand_accu, sin, 1.0e-30)

@test test_atol(rand_bigf, rand_accu, cos, 1.0e-29)
@test test_rtol(rand_bigf, rand_accu, cos, 1.0e-30)

@test test_atol(rand_bigf, rand_accu, tan, 1.0e-29)
@test test_rtol(rand_bigf, rand_accu, tan, 1.0e-30)

@test test_atol(rand_bigf, rand_accu, asin, 1.0e-29)
@test test_rtol(rand_bigf, rand_accu, asin, 1.0e-29)

@test test_atol(rand_bigf, rand_accu, acos, 1.0e-29)
@test test_rtol(rand_bigf, rand_accu, acos, 1.0e-29)

@test test_atol(rand_bigf, rand_accu, atan, 1.0e-29)
@test test_rtol(rand_bigf, rand_accu, atan, 1.0e-29)

@test test_atol(rand_bigf, rand_accu, sinh, 1.0e-29)
@test test_rtol(rand_bigf, rand_accu, sinh, 1.0e-28)

@test test_atol(rand_bigf, rand_accu, cosh, 1.0e-29)
@test test_rtol(rand_bigf, rand_accu, cosh, 1.0e-28)

@test test_atol(rand_bigf, rand_accu, tanh, 1.0e-29)
@test test_rtol(rand_bigf, rand_accu, tanh, 1.0e-28)

@test test_atol(rand_bigf, rand_accu, asinh, 1.0e-29)
@test test_rtol(rand_bigf, rand_accu, asinh, 1.0e-27)

@test test_atol(rand1_bigf, rand1_accu, acosh, 1.0e-29)
@test test_rtol(rand1_bigf, rand1_accu, acosh, 1.0e-27)

@test test_atol(rand_bigf, rand_accu, atanh, 1.0e-29)
@test test_rtol(rand_bigf, rand_accu, atanh, 1.0e-27)

  
@test test_atol(rand20_bigf, rand20_accu, exp, 1.0e-29)
@test test_rtol(rand20_bigf, rand20_accu, exp, 1.5e-31)

@test test_atol(rand20_bigf, rand20_accu, log, 1.0e-29)
@test test_rtol(rand20_bigf, rand20_accu, log, 1.5e-29)

@test test_atol(rand20_bigf, rand20_accu, sin, 1.0e-26)
@test test_rtol(rand20_bigf, rand20_accu, sin, 1.0e-27)

@test test_atol(rand20_bigf, rand20_accu, cos, 1.0e-26)
@test test_rtol(rand20_bigf, rand20_accu, cos, 1.0e-27)

@test test_atol(rand20_bigf, rand20_accu, tan, 1.0e-24)
@test test_rtol(rand20_bigf, rand20_accu, tan, 1.0e-27)

rand_accu = -rand_accu;
rand_bigf = BigFloat.(rand_accu);

rand1_accu = -rand1_accu;
rand1_bigf = BigFloat.(rand1_accu);

rand20_accu = -rand1_accu;
rand20_bigf = BigFloat.(rand20_accu);

@test test_atol(rand_bigf, rand_accu, exp, 1.0e-29)
@test test_rtol(rand_bigf, rand_accu, exp, 1.5e-31)

@test test_atol(rand_bigf, rand_accu, sin, 1.0e-29)
@test test_rtol(rand_bigf, rand_accu, sin, 1.0e-30)

@test test_atol(rand_bigf, rand_accu, cos, 1.0e-29)
@test test_rtol(rand_bigf, rand_accu, cos, 1.0e-30)

@test test_atol(rand_bigf, rand_accu, tan, 1.0e-29)
@test test_rtol(rand_bigf, rand_accu, tan, 1.0e-30)

@test test_atol(rand_bigf, rand_accu, asin, 1.0e-29)
@test test_rtol(rand_bigf, rand_accu, asin, 1.0e-29)

@test test_atol(rand_bigf, rand_accu, acos, 1.0e-29)
@test test_rtol(rand_bigf, rand_accu, acos, 1.0e-29)

@test test_atol(rand_bigf, rand_accu, atan, 1.0e-29)
@test test_rtol(rand_bigf, rand_accu, atan, 1.0e-29)

@test test_atol(rand_bigf, rand_accu, sinh, 1.0e-29)
@test test_rtol(rand_bigf, rand_accu, sinh, 1.0e-28)

@test test_atol(rand_bigf, rand_accu, cosh, 1.0e-29)
@test test_rtol(rand_bigf, rand_accu, cosh, 1.0e-28)

@test test_atol(rand_bigf, rand_accu, tanh, 1.0e-29)
@test test_rtol(rand_bigf, rand_accu, tanh, 1.0e-28)

@test test_atol(rand_bigf, rand_accu, asinh, 1.0e-29)
@test test_rtol(rand_bigf, rand_accu, asinh, 1.0e-27)

@test test_atol(rand_bigf, rand_accu, atanh, 1.0e-29)
@test test_rtol(rand_bigf, rand_accu, atanh, 1.0e-27)

  
@test test_atol(rand20_bigf, rand20_accu, exp, 1.0e-29)
@test test_rtol(rand20_bigf, rand20_accu, exp, 1.5e-31)

@test test_atol(rand20_bigf, rand20_accu, sin, 1.0e-26)
@test test_rtol(rand20_bigf, rand20_accu, sin, 1.0e-27)

@test test_atol(rand20_bigf, rand20_accu, cos, 1.0e-26)
@test test_rtol(rand20_bigf, rand20_accu, cos, 1.0e-27)

@test test_atol(rand20_bigf, rand20_accu, tan, 1.0e-24)
@test test_rtol(rand20_bigf, rand20_accu, tan, 1.0e-27)
