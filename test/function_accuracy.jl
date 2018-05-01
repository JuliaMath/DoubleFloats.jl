
setprecision(BigFloat, 768)
srand(1602)
const nrands = 1_000
rand_accu = rand(Double, nrands)
rand_fast = FastDouble.(rand_accu)
rand_bigf = BigFloat.(rand_accu)

function test_atol(bigf, rnds, fn, tol)
    fn_bigf = map(x->Double(fn(x)), bigf)
    fn_rnds = map(fn, rnds)
    return all(isapprox(fn_bigf, fn_rnds, atol=tol))
end
function test_rtol(bigf, rnds, fn, tol)
    fn_bigf = map(x->Double(fn(x)), bigf)
    fn_rnds = map(fn, rnds)
    return all(isapprox(fn_bigf, fn_rnds, rtol=tol))
end

  
@test test_atol(rand_bigf, rand_accu, exp, 1.0e-29)
@test test_rtol(rand_bigf, rand_accu, exp, 1.0e-30)
@test test_atol(rand_bigf, rand_fast, exp, 1.0e-24)
@test test_rtol(rand_bigf, rand_fast, exp, 1.0e-25)

@test test_atol(rand_bigf, rand_accu, log, 1.0e-29)
@test test_rtol(rand_bigf, rand_accu, log, 1.0e-30)
@test test_atol(rand_bigf, rand_fast, log, 1.0e-24)
@test test_rtol(rand_bigf, rand_fast, log, 1.0e-25)

@test test_atol(rand_bigf, rand_accu, sin, 1.0e-29)
@test test_rtol(rand_bigf, rand_accu, sin, 1.0e-30)
@test test_atol(rand_bigf, rand_fast, sin, 1.0e-22)
@test test_rtol(rand_bigf, rand_fast, sin, 1.0e-25)

@test test_atol(rand_bigf, rand_accu, cos, 1.0e-29)
@test test_rtol(rand_bigf, rand_accu, cos, 1.0e-30)
@test test_atol(rand_bigf, rand_fast, cos, 1.0e-22)
@test test_rtol(rand_bigf, rand_fast, cos, 1.0e-25)

@test test_atol(rand_bigf, rand_accu, tan, 1.0e-29)
@test test_rtol(rand_bigf, rand_accu, tan, 1.0e-30)
@test test_atol(rand_bigf, rand_fast, tan, 1.0e-22)
@test test_rtol(rand_bigf, rand_fast, tan, 1.0e-25)

@test test_atol(rand_bigf, rand_accu, asin, 1.0e-29)
@test test_rtol(rand_bigf, rand_accu, asin, 1.0e-30)
@test test_atol(rand_bigf, rand_fast, asin, 1.0e-23)
@test test_rtol(rand_bigf, rand_fast, asin, 1.0e-25)

@test test_atol(rand_bigf, rand_accu, acos, 1.0e-29)
@test test_rtol(rand_bigf, rand_accu, acos, 1.0e-30)
@test test_atol(rand_bigf, rand_fast, acos, 1.0e-23)
@test test_rtol(rand_bigf, rand_fast, acos, 1.0e-25)

@test test_atol(rand_bigf, rand_accu, atan, 1.0e-29)
@test test_rtol(rand_bigf, rand_accu, atan, 1.0e-30)
@test test_atol(rand_bigf, rand_fast, atan, 1.0e-23)
@test test_rtol(rand_bigf, rand_fast, atan, 1.0e-25)
