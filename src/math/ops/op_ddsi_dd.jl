#=
    compute the nth root of x
    follows mpfun90.f mpnrt

    iteration converges to a^(-1/n)
    the reciprocal of the final approximation is the nth root

    x[k+1] = x[k] + ((x[k] / n) * (1 - (a * (x[k]^n))

    iterations support lesser precision early, roughly doubling
    the precision with each next stage of the iterative process

=#
function rootn_ddsi_dd(a::Tuple{T,T}, n::Signed) where {T<:IEEEFloat}
    one1 = one(T)
    hi, lo = a
    n_fp = T(n)
    n_inv = inv_fp_dd(n_fp)
    # initial approximation
    x = inv(hi)^(HI(n_inv))

    m = n
    xon = dvi_fpfp_dd(x, n_fp)
    xpn = mul_fpfp_dd(x, x)
    m -= 2
    while m > 0
       xpn = mul_fpdd_dd(x, xpn)
       m -= 1
    end
    axn = mul_dddd_dd(a, xpn)
    axn = sub_fpdd_dd(one1, axn)
    xon = mul_dddd_dd(xon, axn)
    x = add_fpdd_dd(x, xon)

    m = n
    xon = dvi_ddfp_dd(x, n_fp)
    xpn = mul_dddd_dd(x, x)
    m -= 2
    while m > 0
       xpn = mul_dddd_dd(x, xpn)
       m -= 1
    end
    axn = mul_dddd_dd(a, xpn)
    axn = sub_fpdd_dd(one1, axn)
    xon = mul_dddd_dd(xon, axn)
    x = add_dddd_dd(x, xon)

    m = n
    xon = dvi_ddfp_dd(x, n_fp)
    xpn = mul_dddd_dd(x, x)
    m -= 2
    while m > 0
       xpn = mul_dddd_dd(x, xpn)
       m -= 1
    end
    axn = mul_dddd_dd(a, xpn)
    axn = sub_fpdd_dd(one1, axn)
    xon = mul_dddd_dd(xon, axn)
    x = add_dddd_dd(x, xon)

    x = inv_dd_dd(x)
    return x
end


function root5_ddsi_dd(a::Tuple{T,T}, n::Signed) where {T<:IEEEFloat}
    one1 = one(T)
    hi, lo = a
    n_fp = T(n)
    n_inv = inv_fp_dd(n_fp)
    # initial approximation
    x = inv(hi)^(HI(n_inv))

   # m = n
    xon = dvi_fpfp_dd(x, n_fp)
    xpn = mul_fpfp_dd(x, x)
    xpn = mul_fpdd_dd(x, xpn)
    xpn = mul_fpdd_dd(x, xpn)
    xpn = mul_fpdd_dd(x, xpn)
   # m -= 2
   # while m > 0
   #    xpn = mul_fpdd_dd(x, xpn)
   #    m -= 1
   # end
    axn = mul_dddd_dd(a, xpn)
    axn = sub_fpdd_dd(one1, axn)
    xon = mul_dddd_dd(xon, axn)
    x = add_fpdd_dd(x, xon)

    #m = n
    xon = dvi_ddfp_dd(x, n_fp)
    xpn = mul_dddd_dd(x, x)
    xpn = mul_dddd_dd(x, xpn)
    xpn = mul_dddd_dd(x, xpn)
    xpn = mul_dddd_dd(x, xpn)
   #
    #m -= 2
    #while m > 0
    #   xpn = mul_dddd_dd(x, xpn)
    #   m -= 1
    #end
    axn = mul_dddd_dd(a, xpn)
    axn = sub_fpdd_dd(one1, axn)
    xon = mul_dddd_dd(xon, axn)
    x = add_dddd_dd(x, xon)

   # m = n
    xon = dvi_ddfp_dd(x, n_fp)
    xpn = mul_dddd_dd(x, x)
    xpn = mul_dddd_dd(x, xpn)
    xpn = mul_dddd_dd(x, xpn)
    xpn = mul_dddd_dd(x, xpn)

   # m -= 2
   # while m > 0
   #    xpn = mul_dddd_dd(x, xpn)
   #    m -= 1
   # end
    axn = mul_dddd_dd(a, xpn)
    axn = sub_fpdd_dd(one1, axn)
    xon = mul_dddd_dd(xon, axn)
    x = add_dddd_dd(x, xon)

    x = inv_dd_dd(x)
    return x
end
