@testset "op_dd_dd" begin
    t = sqrt(Double64(0.5))
   
    @test sum(abs.(HILO(gamma_df64) .- @df(inv_dd_dd, @df(inv_dd_dd, HILO(gamma_df64))))) < 1.0e-30
 
end

@testset "leasterror nonfinite corner cases" begin
    @test @df(two_inv, 1.0e-310) == (Inf, 0.0)
    @test @df(two_dvi, 2.0, 1.0e-310) == (Inf, 0.0)
    @test @df(two_sqrt, Inf) == (Inf, 0.0)

    @test @df(two_inv, Inf) == (0.0, 0.0)
    @test @df(two_dvi, 2.0, Inf) == (0.0, 0.0)
    @test @df(two_sqrt, 0.0) == (0.0, 0.0)
end
