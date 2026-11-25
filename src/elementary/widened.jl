#   :asin, :acos, :atan, :acsc, :asec, :acot, in arctrig.jl

const _DOUBLE32_WIDENED = (:expm1, :log, :log2, :log1p, :atan, :tan, :sinh, :cosh, :tanh)

for F in (# :mod2pi, :square, :cube, :sqrt,
    :cbrt,
    :exp,
    :expm1,
    :log,
    :log1p,
    :log2,
    :log10,
    :sin,
    :cos,
    :tan,
    :csc,
    :sec,
    :cot,
    :sinh,
    :cosh,
    :tanh,
    :csch,
    :sech,
    :coth,
    :asinh,
    :acosh,
    :atanh,
    :acsch,
    :asech,
    :acoth,
)
    @eval begin
        if $(F !== :exp && F ∉ _DOUBLE32_WIDENED)
            $F(x::Double32) = Double32($F(Double64(x)))
        end
        $F(x::Double16) = Double16($F(Double64(x)))
        $F(x::DoubleFloat{Double32}) = DoubleFloat{Double32}($F(DoubleFloat{Double64}(x)))
        $F(x::DoubleFloat{Double16}) = DoubleFloat{Double16}($F(DoubleFloat{Double64}(x)))
    end
end
