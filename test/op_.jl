@testset "op_dd_dd" begin
    t = sqrt(Double64(0.5))
   
    @test @df(neg_dd_dd, HILO(gamma_df64)) == HILO(-gamma_df64)
    @test @df(abs_dd_dd, HILO(-gamma_df64)) == HILO(gamma_df64)
    @test sum(@df(negabs_dd_dd, HILO(-(gamma_df32))) .- HILO(-(abs(-gamma_df32)))) < 1.0e-30
    @test sum(abs.(HILO(gamma_df64) .- @df(inv_dd_dd, @df(inv_dd_dd, HILO(gamma_df64))))) < 1.0e-30

    @test @df(negabs_dd_dd, HILO(t)) == (0.7071067811865476, -4.8336466567264573e-17)
    @test @df(cube_dd_dd, HILO(t)) == (0.3535533905932738, -2.416823328363229e-17)
    @test @df(inv_dd_dd_fast, HILO(t)) == (1.4142135623730951, -9.667293313452913e-17)    
end
