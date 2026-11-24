const _SINH_LOCAL, _COSH_LOCAL, _TAN_CORRECTION, _TAN_DENOMINATOR =
    setprecision(BigFloat, 256) do
        sinh_coeffs = ntuple(i -> HILO(Double64(inv(BigFloat(factorial(big(2i + 1)))))), 15)
        cosh_coeffs = ntuple(i -> HILO(Double64(inv(BigFloat(factorial(big(2i)))))), 15)

        # Lambert's continued fraction for tanh(x)/x. If z = x² and
        # the inner fraction is p/q, the correction is z*q/(p+z*q).
        p, q = BigInt[31], BigInt[1]
        for j in 14:-1:1
            next = (2j + 1) .* p
            append!(next, zeros(BigInt, max(0, length(q) + 1 - length(p))))
            next[2:length(q)+1] .+= q
            p, q = next, p
        end
        denominator = copy(p)
        append!(denominator, zeros(BigInt, max(0, length(q) + 1 - length(p))))
        denominator[2:length(q)+1] .+= q
        scale = BigFloat(p[1])
        pack(xs) = Tuple(HILO(Double64(BigFloat(x) / scale)) for x in xs)
        sinh_coeffs, cosh_coeffs, pack(q), pack(denominator)
    end

@inline function _local_poly(z, c)
    p = c[end]
    for i in length(c)-1:-1:1
        p = _horner_step_dd(c[i], p, z)
    end
    return p
end

@inline function _sinh_local(x::Double64)
    abs(HI(x)) <= 0x1p-53 && return x
    p = HILO(x)
    z = square_dd_dd_(p)
    correction = mul_dddd_dd_(mul_dddd_dd_(p, z), _tapered_poly(z, _SINH_LOCAL, Val(8)))
    return Double64(add_dddd_dd_(p, correction)...)
end

@inline function _cosh_local(x::Double64)
    z = square_dd_dd_(HILO(x))
    return Double64(_horner_step_dd((1.0, 0.0), _tapered_poly(z, _COSH_LOCAL, Val(9)), z)...)
end

@inline function _tan_local(x::Double64, ::Val{C}) where {C}
    abs(HI(x)) <= 0x1p-53 && return x
    p = HILO(x)
    zz = square_dd_dd_(p)
    z = C ? (-zz[1], -zz[2]) : zz
    q = _local_poly(z, _TAN_DENOMINATOR)
    n = mul_dddd_dd_(z, _local_poly(z, _TAN_CORRECTION))
    correction = dvi_dddd_dd_(n, q)
    return Double64(sub_dddd_dd_(p, mul_dddd_dd_(p, correction))...)
end

@inline _tanh_local(x::Double64) = _tan_local(x, Val(false))
@inline _tan_local(x::Double64) = _tan_local(x, Val(true))
