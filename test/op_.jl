@testset "op_fp_dd" begin

    @test @df(neg_fp_dd, HI(gamma_df64)) == HI(-gamma_df64)
    @test @df(abs_fp_dd, HI(-gamma_df64)) == HI(gamma_df64)
    @test sum(@df(negabs_fp_dd, HI(-(gamma_df32))) .- HI(-(abs(-gamma_df32)))) < 1.0e-15
    @test sum(abs.(HI(gamma_df64) .- @df(inv_fp_dd, @df(inv_fp_dd, HI(gamma_df64))))) < 1.0e-15

end

@testset "op_dd_dd" begin

    @test @df(neg_dd_dd, HILO(gamma_df64)) == HILO(-gamma_df64)
    @test @df(abs_dd_dd, HILO(-gamma_df64)) == HILO(gamma_df64)
    @test sum(@df(negabs_dd_dd, HILO(-(gamma_df32))) .- HILO(-(abs(-gamma_df32)))) < 1.0e-30
    @test sum(abs.(HILO(gamma_df64) .- @df(inv_dd_dd, @df(inv_dd_dd, HILO(gamma_df64))))) < 1.0e-30

end
