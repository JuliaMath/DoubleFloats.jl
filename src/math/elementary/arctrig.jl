for F in (:asin, :acos, :atan, :acsc, :asec, :acot)
    @eval begin
      $F(x::Double64) = Double64Float128($F, x)
      $F(x::Double32) = Double32Float128($F, x)
      $F(x::Double16) = Double16Float128($F, x)
    end
end

atan(y::Double64, x::Double64) = Double64(atan(Quadmath.Float128(y), Quadmath.Float128(x)))
atan(y::Double32, x::Double32) = Double32(atan(Quadmath.Float128(y), Quadmath.Float128(x)))
atan(y::Double16, x::Double16) = Double16(atan(Quadmath.Float128(y), Quadmath.Float128(x)))
