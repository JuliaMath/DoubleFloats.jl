@testset "Matmul" begin

    # Test multiplications with Double64 and Float64
    A1 = [1.0 2 3; 4 5 6; 7 8 9]
    B1 = [7.0 8; 9 10; 11 12]
    A1B1 = A1*B1

    DA1DB1 = Double64.(A1)*Double64.(B1)
    DA1FB1 = Double64.(A1)*B1
    FA1DB1 = A1*Double64.(B1)

    @test DA1DB1 == Double64.(A1B1)
    @test DA1FB1 == Double64.(A1B1)
    @test FA1DB1 == Double64.(A1B1)
    @test DA1DB1 isa Array{Double64,2}
    @test DA1FB1 isa Array{Double64,2}
    @test FA1DB1 isa Array{Double64,2}

    # Also test transpose
    @test Double64.(B1)'Double64.(A1)' == Double64.(A1B1')
    # Incompatible Dimension
    @test_throws DimensionMismatch Double64.(B1)*Double64.(A1)

    #Test with zero inner dimension (zero result)
    A2 = Array{Float64,2}(undef, 2, 0)
    B2 = Array{Float64,2}(undef, 0, 3)
    A2B2 = A2*B2

    DA2DB2 = Double64.(A2)*Double64.(B2)
    DA2FB2 = Double64.(A2)*B2
    FA2DB2 = A2*Double64.(B2)

    @test DA2DB2 == Double64.(A2B2)
    @test DA2FB2 == Double64.(A2B2)
    @test FA2DB2 == Double64.(A2B2)
    @test DA2DB2 isa Array{Double64,2}
    @test DA2FB2 isa Array{Double64,2}
    @test FA2DB2 isa Array{Double64,2}


    #Test with zero outer dimensions (empty result)
    A3 = Array{Float64,2}(undef, 0, 3)
    B3 = Array{Float64,2}(undef, 3, 0)
    A3B3 = A3*B3

    DA3DB3 = Double64.(A3)*Double64.(B3)
    DA3FB3 = Double64.(A3)*B3
    FA3DB3 = A3*Double64.(B3)

    @test DA3DB3 == Double64.(A3B3)
    @test DA3FB3 == Double64.(A3B3)
    @test FA3DB3 == Double64.(A3B3)
    @test DA3DB3 isa Array{Double64,2}
    @test DA3FB3 isa Array{Double64,2}
    @test FA3DB3 isa Array{Double64,2}

    #Test multiplications with ComplexD64
    C1  = [1.0+2*im 3 4*im; 5 6 7-im]
    C1T = transpose(C1)
    C2  = [im; 0; 5-7*im]
    C1C2 = C1*C2
    C1C1T = C1*C1T
    DC1DC2  = ComplexDF64.(C1)*ComplexDF64.(C2)
    DC1DC1T = ComplexDF64.(C1)*ComplexDF64.(C1T)
    DC1FC2  = ComplexDF64.(C1)*C2
    FC1DC2  = C1*ComplexDF64.(C2)

    @test DC1DC2  == ComplexDF64.(C1C2)
    @test DC1DC1T == ComplexDF64.(C1C1T)
    @test DC1FC2  == ComplexDF64.(C1C2)
    @test FC1DC2  == ComplexDF64.(C1C2)
    # ComplexD64 is not a type, it is a constructor function
    @test DC1DC2  isa Array{Complex{DoubleFloat{Float64}},1}
    @test DC1DC1T isa Array{Complex{DoubleFloat{Float64}},2}
    @test DC1FC2  isa Array{Complex{DoubleFloat{Float64}},1}
    @test FC1DC2  isa Array{Complex{DoubleFloat{Float64}},1}

end
