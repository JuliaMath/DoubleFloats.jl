# Other parts of the Base contract touched in Stage 1.

@testset "approximation and random numbers" begin
    for T in CONFORMANCE_TYPES
        name = typename(T)
        F = wordof(T)

        property("misc/isapprox with keywords, same type/" * name) do
            isapprox(T(1), T(1) + T(F(1e-3)); rtol = 1e-2) && !isapprox(T(1), T(2); atol = 0.5)
        end
        property("misc/isapprox with keywords, mixed types/" * name) do
            isapprox(T(1), F(1); rtol = 1e-3) && isapprox(F(1), T(1); atol = 1e-3) && isapprox(T(1), 1; rtol = 1e-3)
        end
        property("misc/isapprox default tolerance/" * name) do
            isapprox(T(1), T(1) + eps(T)) && !isapprox(T(1), T(1) + sqrt(sqrt(eps(T))))
        end
        property("misc/isapprox with NaN/" * name) do
            !isapprox(T(F(NaN)), T(F(NaN))) && isapprox(T(F(NaN)), T(F(NaN)); nans = true)
        end
        property("misc/rand is in the unit interval/" * name) do
            v = rand(Random.Xoshiro(1), T, 200)
            all(x -> 0 <= x < 1, v) && all(x -> HI(x) + LO(x) == HI(x), v)
        end
        property("misc/rand fills the low word/" * name) do
            any(x -> !iszero(LO(x)), rand(Random.Xoshiro(1), T, 200))
        end
        property("misc/rand accepts any generator/" * name) do
            rand(Random.Xoshiro(1), T) isa T &&
                rand(Random.MersenneTwister(1), T) isa T &&
                rand(Random.Xoshiro(1), T) == rand(Random.Xoshiro(1), T)
        end
        property("misc/randn/" * name) do
            randn(Random.Xoshiro(1), T) isa T && isfinite(randn(Random.Xoshiro(2), T))
        end
        property("misc/randpm accepts any generator/" * name) do
            DoubleFloats.randpm(Random.Xoshiro(1), T) isa T
        end
        property("misc/csc and sec are Base methods/" * name) do
            x = T(F(0.5))
            which(csc, Tuple{T}).module === DoubleFloats && which(sec, Tuple{T}).module === DoubleFloats
        end
        property("misc/clamp/" * name) do
            clamp(T(5), T(1), T(2)) == 2 && clamp(T(5), 1, 2) == 2
        end
    end
    property("misc/@via_df32 returns Float32 for one, two, and three arrays") do
        a = Float32[1, 2]
        eltype(@via_df32(sqrt, a)) === Float32 &&
            eltype(@via_df32(+, a, a)) === Float32 &&
            eltype(@via_df32(fma, a, a, a)) === Float32
    end
    property("misc/@via_df64 returns Float64 for one, two, and three arrays") do
        a = [1.0, 2.0]
        eltype(@via_df64(sqrt, a)) === Float64 &&
            eltype(@via_df64(+, a, a)) === Float64 &&
            eltype(@via_df64(fma, a, a, a)) === Float64
    end
    property("misc/no public function changes BigFloat precision") do
        before = precision(BigFloat)
        string(Double64(1) / 3)
        Double64(big(1) / 3)
        exp(Double64(1))
        precision(BigFloat) == before
    end
end
