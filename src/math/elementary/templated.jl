for F in (# :mod2pi, :square, :cube, :sqrt, 
          :cbrt,
          :exp, :expm1, :log, :log1p, :log2, :log10, 
          :sin, :cos, :tan, :csc, :sec, :cot,
          :asin, :acos, :atan, :acsc, :asec, :acot,
          :sinh, :cosh, :tanh, :csch, :sech, :coth,
          :asinh, :acosh, :atanh, :acsch, :asech, :acoth)
  @eval begin
    $F(x::DoubleF32) = DoubleF32($F(DoubleF64(x)))
    $F(x::DoubleF16) = DoubleF16($F(DoubleF64(x)))
    $F(x::DoubleFloat{DoubleF32}) = DoubleFloat{DoubleF32}($F(DoubleFloat{DoubleF64}(x)))
    $F(x::DoubleFloat{DoubleF16}) = DoubleFloat{DoubleF16}($F(DoubleFloat{DoubleF64}(x)))
  end
end
