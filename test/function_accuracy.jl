
setprecision(BigFloat, 512)
srand(1602);
const nrands = 1_000 # tested with nrands = 100_000

rand_accu = rand(Double, nrands);
rand_fast = FastDouble.(rand_accu);
rand_bigf = BigFloat.(rand_accu);

rand1_accu = rand_accu .+ 1.0;
rand1_fast = FastDouble.(rand1_accu);
rand1_bigf = BigFloat.(rand1_accu);

rand20_accu = rand_accu .* 20.0;
rand20_fast = FastDouble.(rand20_accu);
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
@test test_atol(rand_bigf, rand_fast, exp, 1.0e-29)
@test test_rtol(rand_bigf, rand_fast, exp, 1.0e-30)

@test test_atol(rand_bigf, rand_accu, log, 1.0e-29)
@test test_rtol(rand_bigf, rand_accu, log, 1.5e-29)
@test test_atol(rand_bigf, rand_fast, log, 1.0e-29)
@test test_rtol(rand_bigf, rand_fast, log, 1.5e-28)

@test test_atol(rand_bigf, rand_accu, sin, 1.0e-29)
@test test_rtol(rand_bigf, rand_accu, sin, 1.0e-30)
@test test_atol(rand_bigf, rand_fast, sin, 1.0e-21)
@test test_rtol(rand_bigf, rand_fast, sin, 1.0e-21)

@test test_atol(rand_bigf, rand_accu, cos, 1.0e-29)
@test test_rtol(rand_bigf, rand_accu, cos, 1.0e-30)
@test test_atol(rand_bigf, rand_fast, cos, 1.0e-21)
@test test_rtol(rand_bigf, rand_fast, cos, 1.0e-21)

@test test_atol(rand_bigf, rand_accu, tan, 1.0e-29)
@test test_rtol(rand_bigf, rand_accu, tan, 1.0e-30)
@test test_atol(rand_bigf, rand_fast, tan, 1.5e-21)
@test test_rtol(rand_bigf, rand_fast, tan, 1.0e-21)

@test test_atol(rand_bigf, rand_accu, asin, 1.0e-29)
@test test_rtol(rand_bigf, rand_accu, asin, 1.0e-29)
@test test_atol(rand_bigf, rand_fast, asin, 1.0e-21)
@test test_rtol(rand_bigf, rand_fast, asin, 1.0e-21)

@test test_atol(rand_bigf, rand_accu, acos, 1.0e-29)
@test test_rtol(rand_bigf, rand_accu, acos, 1.0e-29)
@test test_atol(rand_bigf, rand_fast, acos, 1.0e-21)
@test test_rtol(rand_bigf, rand_fast, acos, 1.0e-21)

@test test_atol(rand_bigf, rand_accu, atan, 1.0e-29)
@test test_rtol(rand_bigf, rand_accu, atan, 1.0e-29)
@test test_atol(rand_bigf, rand_fast, atan, 1.0e-21)
@test test_rtol(rand_bigf, rand_fast, atan, 1.0e-21)



@test test_atol(rand_bigf, rand_accu, sinh, 1.0e-29)
@test test_rtol(rand_bigf, rand_accu, sinh, 1.0e-28)
@test test_atol(rand_bigf, rand_fast, sinh, 1.0e-21)
@test test_rtol(rand_bigf, rand_fast, sinh, 1.0e-21)

@test test_atol(rand_bigf, rand_accu, cosh, 1.0e-29)
@test test_rtol(rand_bigf, rand_accu, cosh, 1.0e-28)
@test test_atol(rand_bigf, rand_fast, cosh, 1.0e-21)
@test test_rtol(rand_bigf, rand_fast, cosh, 1.0e-21)

@test test_atol(rand_bigf, rand_accu, tanh, 1.0e-29)
@test test_rtol(rand_bigf, rand_accu, tanh, 1.0e-28)
@test test_atol(rand_bigf, rand_fast, tanh, 1.5e-21)
@test test_rtol(rand_bigf, rand_fast, tanh, 1.0e-21)

@test test_atol(rand_bigf, rand_accu, asinh, 1.0e-29)
@test test_rtol(rand_bigf, rand_accu, asinh, 1.0e-27)
@test test_atol(rand_bigf, rand_fast, asinh, 1.0e-23)
@test test_rtol(rand_bigf, rand_fast, asinh, 1.0e-25)

@test test_atol(rand1_bigf, rand1_accu, acosh, 1.0e-29)
@test test_rtol(rand1_bigf, rand1_accu, acosh, 1.0e-27)
@test test_atol(rand1_bigf, rand1_fast, acosh, 1.0e-23)
@test test_rtol(rand1_bigf, rand1_fast, acosh, 1.0e-25)

@test test_atol(rand_bigf, rand_accu, atanh, 1.0e-29)
@test test_rtol(rand_bigf, rand_accu, atanh, 1.0e-27)
@test test_atol(rand_bigf, rand_fast, atanh, 1.0e-23)
@test test_rtol(rand_bigf, rand_fast, atanh, 1.0e-25)



  
@test test_atol(rand20_bigf, rand20_accu, exp, 1.0e-29)
@test test_rtol(rand20_bigf, rand20_accu, exp, 1.5e-31)
@test test_atol(rand20_bigf, rand20_fast, exp, 1.0e-29)
@test test_rtol(rand20_bigf, rand20_fast, exp, 1.0e-30)

@test test_atol(rand20_bigf, rand20_accu, log, 1.0e-29)
@test test_rtol(rand20_bigf, rand20_accu, log, 1.5e-29)
@test test_atol(rand20_bigf, rand20_fast, log, 1.0e-29)
@test test_rtol(rand20_bigf, rand20_fast, log, 1.5e-28)

@test test_atol(rand20_bigf, rand20_accu, sin, 1.0e-26)
@test test_rtol(rand20_bigf, rand20_accu, sin, 1.0e-27)
@test test_atol(rand20_bigf, rand20_fast, sin, 1.0e-18)
@test test_rtol(rand20_bigf, rand20_fast, sin, 1.0e-19)

@test test_atol(rand20_bigf, rand20_accu, cos, 1.0e-26)
@test test_rtol(rand20_bigf, rand20_accu, cos, 1.0e-27)
@test test_atol(rand20_bigf, rand20_fast, cos, 1.0e-18)
@test test_rtol(rand20_bigf, rand20_fast, cos, 1.0e-19)

@test test_atol(rand20_bigf, rand20_accu, tan, 1.0e-24)
@test test_rtol(rand20_bigf, rand20_accu, tan, 1.0e-27)
@test test_atol(rand20_bigf, rand20_fast, tan, 1.0e-16)
@test test_rtol(rand20_bigf, rand20_fast, tan, 1.0e-19)

rand_accu = -rand_accu;
rand_fast = FastDouble.(rand_accu);
rand_bigf = BigFloat.(rand_accu);

rand1_accu = -rand1_accu;
rand1_fast = FastDouble.(rand1_accu);
rand1_bigf = BigFloat.(rand1_accu);

rand20_accu = -rand1_accu;
rand20_fast = FastDouble.(rand20_accu);
rand20_bigf = BigFloat.(rand20_accu);

@test test_atol(rand_bigf, rand_accu, exp, 1.0e-29)
@test test_rtol(rand_bigf, rand_accu, exp, 1.5e-31)
@test test_atol(rand_bigf, rand_fast, exp, 1.0e-29)
@test test_rtol(rand_bigf, rand_fast, exp, 1.0e-30)

@test test_atol(rand_bigf, rand_accu, sin, 1.0e-29)
@test test_rtol(rand_bigf, rand_accu, sin, 1.0e-30)
@test test_atol(rand_bigf, rand_fast, sin, 1.0e-21)
@test test_rtol(rand_bigf, rand_fast, sin, 1.0e-21)

@test test_atol(rand_bigf, rand_accu, cos, 1.0e-29)
@test test_rtol(rand_bigf, rand_accu, cos, 1.0e-30)
@test test_atol(rand_bigf, rand_fast, cos, 1.0e-21)
@test test_rtol(rand_bigf, rand_fast, cos, 1.0e-21)

@test test_atol(rand_bigf, rand_accu, tan, 1.0e-29)
@test test_rtol(rand_bigf, rand_accu, tan, 1.0e-30)
@test test_atol(rand_bigf, rand_fast, tan, 1.5e-21)
@test test_rtol(rand_bigf, rand_fast, tan, 1.0e-21)

@test test_atol(rand_bigf, rand_accu, asin, 1.0e-29)
@test test_rtol(rand_bigf, rand_accu, asin, 1.0e-29)
@test test_atol(rand_bigf, rand_fast, asin, 1.0e-21)
@test test_rtol(rand_bigf, rand_fast, asin, 1.0e-21)

@test test_atol(rand_bigf, rand_accu, acos, 1.0e-29)
@test test_rtol(rand_bigf, rand_accu, acos, 1.0e-29)
@test test_atol(rand_bigf, rand_fast, acos, 1.0e-21)
@test test_rtol(rand_bigf, rand_fast, acos, 1.0e-21)

@test test_atol(rand_bigf, rand_accu, atan, 1.0e-29)
@test test_rtol(rand_bigf, rand_accu, atan, 1.0e-29)
@test test_atol(rand_bigf, rand_fast, atan, 1.0e-21)
@test test_rtol(rand_bigf, rand_fast, atan, 1.0e-21)



@test test_atol(rand_bigf, rand_accu, sinh, 1.0e-29)
@test test_rtol(rand_bigf, rand_accu, sinh, 1.0e-28)
@test test_atol(rand_bigf, rand_fast, sinh, 1.0e-21)
@test test_rtol(rand_bigf, rand_fast, sinh, 1.0e-21)

@test test_atol(rand_bigf, rand_accu, cosh, 1.0e-29)
@test test_rtol(rand_bigf, rand_accu, cosh, 1.0e-28)
@test test_atol(rand_bigf, rand_fast, cosh, 1.0e-21)
@test test_rtol(rand_bigf, rand_fast, cosh, 1.0e-21)

@test test_atol(rand_bigf, rand_accu, tanh, 1.0e-29)
@test test_rtol(rand_bigf, rand_accu, tanh, 1.0e-28)
@test test_atol(rand_bigf, rand_fast, tanh, 1.5e-21)
@test test_rtol(rand_bigf, rand_fast, tanh, 1.0e-21)

@test test_atol(rand_bigf, rand_accu, asinh, 1.0e-29)
@test test_rtol(rand_bigf, rand_accu, asinh, 1.0e-27)
@test test_atol(rand_bigf, rand_fast, asinh, 1.0e-23)
@test test_rtol(rand_bigf, rand_fast, asinh, 1.0e-25)

@test test_atol(rand1_bigf, rand1_accu, acosh, 1.0e-29)
@test test_rtol(rand1_bigf, rand1_accu, acosh, 1.0e-27)
@test test_atol(rand1_bigf, rand1_fast, acosh, 1.0e-23)
@test test_rtol(rand1_bigf, rand1_fast, acosh, 1.0e-25)

@test test_atol(rand_bigf, rand_accu, atanh, 1.0e-29)
@test test_rtol(rand_bigf, rand_accu, atanh, 1.0e-27)
@test test_atol(rand_bigf, rand_fast, atanh, 1.0e-23)
@test test_rtol(rand_bigf, rand_fast, atanh, 1.0e-25)



  
@test test_atol(rand20_bigf, rand20_accu, exp, 1.0e-29)
@test test_rtol(rand20_bigf, rand20_accu, exp, 1.5e-31)
@test test_atol(rand20_bigf, rand20_fast, exp, 1.0e-29)
@test test_rtol(rand20_bigf, rand20_fast, exp, 1.0e-30)

@test test_atol(rand20_bigf, rand20_accu, log, 1.0e-29)
@test test_rtol(rand20_bigf, rand20_accu, log, 1.5e-29)
@test test_atol(rand20_bigf, rand20_fast, log, 1.0e-29)
@test test_rtol(rand20_bigf, rand20_fast, log, 1.5e-28)

@test test_atol(rand20_bigf, rand20_accu, sin, 1.0e-26)
@test test_rtol(rand20_bigf, rand20_accu, sin, 1.0e-27)
@test test_atol(rand20_bigf, rand20_fast, sin, 1.0e-18)
@test test_rtol(rand20_bigf, rand20_fast, sin, 1.0e-19)

@test test_atol(rand20_bigf, rand20_accu, cos, 1.0e-26)
@test test_rtol(rand20_bigf, rand20_accu, cos, 1.0e-27)
@test test_atol(rand20_bigf, rand20_fast, cos, 1.0e-18)
@test test_rtol(rand20_bigf, rand20_fast, cos, 1.0e-19)
#=
@test test_atol(rand20_bigf, rand20_accu, tan, 1.0e-24)
@test test_rtol(rand20_bigf, rand20_accu, tan, 1.0e-27)
@test test_atol(rand20_bigf, rand20_fast, tan, 1.0e-16)
@test test_rtol(rand20_bigf, rand20_fast, tan, 1.0e-19)
=#
