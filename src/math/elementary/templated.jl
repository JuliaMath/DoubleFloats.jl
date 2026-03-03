#   :asin, :acos, :atan, :acsc, :asec, :acot, in arctrig.jl

for F in (# :mod2pi, :square, :cube, :sqrt,
          :cbrt,
          :exp, :expm1, :log, :log1p, :log2, :log10,
          :sin, :cos, :tan, :csc, :sec, :cot,
          :sinh, :cosh, :tanh, :csch, :sech, :coth,
          :asinh, :acosh, :atanh, :acsch, :asech, :acoth)
  @eval begin
    $F(x::Double32) = Double32($F(Double64(x)))
    $F(x::Double16) = Double16($F(Double64(x)))
    $F(x::DoubleFloat{Double32}) = DoubleFloat{Double32}($F(DoubleFloat{Double64}(x)))
    $F(x::DoubleFloat{Double16}) = DoubleFloat{Double16}($F(DoubleFloat{Double64}(x)))
  end
end
