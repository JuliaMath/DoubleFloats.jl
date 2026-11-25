s1 = "12.125"; v1 = 12.125
s2 = "-0.125"; v2 = -0.125
s3 = "5"     ; v3 = 5

@testset "parse $T" for T in (Double16, Double32, Double64)
  
@test T(s1) === T(v1)
@test T(s2) === T(v2)
@test T(s3) === T(v3)
 
end

@testset "T_str" begin

@test df64"12.125" === Double64(s1)
@test df32"-0.125" === Double32(s2)
@test df16"5" === Double16(s3)

end
