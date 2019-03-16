@testset "op_dd_dd" begin

    @test @df(neg_dd_dd, HILO(gamma_df64)) == HILO(-gamma_df64)
    @test @df(abs_dd_dd, HILO(-gamma_df64)) == HILO(gamma_df64)
    @test @df(negabs_dd_dd, HILO(gmma_df32)) == (-abs(HI(gamma_df32)), -abs(LO(gamma_df32)))
    @test sum(abs.(HILO(gamma_df64) .- @df(inv_dd_dd, @df(inv_dd_dd, HILO(gamma_df64))))) < 1.0e-30

end
