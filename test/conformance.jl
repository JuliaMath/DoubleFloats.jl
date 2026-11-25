include("conformance/support.jl")

@testset "conformance" begin
    include("conformance/order.jl")
    include("conformance/construct.jl")
    include("conformance/convert.jl")
    include("conformance/parse.jl")
    include("conformance/promote.jl")
    include("conformance/misc.jl")
end

if CONFORMANCE_RECORD
    write(joinpath(@__DIR__, "conformance", "broken.txt"), join(sort!(unique!(CONFORMANCE_FAILED)), "\n"), "\n")
    println("recorded ", length(CONFORMANCE_FAILED), " properties that do not hold")
end
