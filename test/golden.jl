# Results must have the bits recorded in golden/corpus.toml.
#
# A change that only moves or renames code must leave this suite passing with
# the corpus untouched. A change that alters a result regenerates the entries
# it means to alter, in the same commit. See golden/diff.jl to list the inputs
# behind a failing block.

using TOML

include("golden/subjects.jl")

@testset "golden corpus" begin
    expected = TOML.parsefile(joinpath(@__DIR__, "golden", "corpus.toml"))
    actual = golden()
    @test sort!(collect(keys(actual))) == sort!(collect(keys(expected)))
    different = String[]
    for key in sort!(collect(keys(expected)))
        haskey(actual, key) || continue
        if actual[key] != expected[key]
            blocks = findall(i -> get(actual[key], i, "") != get(expected[key], i, ""),
                             1:max(length(actual[key]), length(expected[key])))
            push!(different, string(key, " blocks ", join(blocks, ",")))
        end
    end
    isempty(different) || println("golden corpus differs:\n  ", join(different, "\n  "))
    @test isempty(different)
end
