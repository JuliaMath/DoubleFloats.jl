# Record the golden corpus from whichever DoubleFloats the active project
# provides:
#
#     julia --project=ENV test/golden/generate.jl [OUTPUT]
#
# The baseline in `corpus.toml` was recorded from the head of `release-1.13`.

using DoubleFloats
using TOML

include(joinpath(@__DIR__, "..", "support", "splitmix.jl"))
include(joinpath(@__DIR__, "subjects.jl"))

function writecorpus(path, corpus)
    open(path, "w") do io
        println(io, "# Checksums of output bits, one per block of ", GOLDEN_BLOCK, " inputs.")
        println(io, "# Written by test/golden/generate.jl. Do not edit by hand.")
        for key in sort!(collect(keys(corpus)))
            println(io, repr(key), " = [", join(repr.(corpus[key]), ", "), "]")
        end
    end
end

output = isempty(ARGS) ? joinpath(@__DIR__, "corpus.toml") : ARGS[1]
writecorpus(output, golden())
println("wrote ", output, " from DoubleFloats ", pkgversion(DoubleFloats))
