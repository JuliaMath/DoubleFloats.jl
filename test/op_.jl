@testset "op_dd_dd" begin
    @test @df(neg_dd_dd, HILO(golden_df64)) == HILO(-golden_df64)
    @test @df(abs_dd_dd, HILO(-golden_df64)) == HILO(golden_df64)
    @test @df(negabs_dd_dd, HILO(golden_df32)) == (-abs(HI(golden_df32)), -abs(LO(golden_df32))
    @test sum(abs.(HILO(golden_df64) .- @df(inv_dd_dd, @df(inv_dd_dd, HILO(golden_df64))))) < 1.0e-30
end
