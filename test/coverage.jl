@testset "convert"

bf = BigFloat(pi)
df = Double64(bf)
sqrt2 = sqrt(2.0)

@test BigFloat(df) == convert(BigFloat, df)
@test Double64(bf) == convert(Double64, bf)

@test Double32(sqrt2) == convert(Double32, sqrt2)
@test Double64(sqrt2) == convert(Double64, sqrt2)

end # convert
