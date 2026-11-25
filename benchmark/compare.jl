# Compare the speed of two versions of DoubleFloats on this machine.
#
#     julia benchmark/compare.jl A B [THRESHOLD] [ROUNDS]
#
# A and B each name a version: a registered version number, `rev:NAME` for a
# branch, tag, or commit of the GitHub repository, or `path:DIR` for a local
# checkout. The suite in benchmarks.jl (this copy of it) is run against each,
# alternately, ROUNDS times (default 2), and the minimum time of each
# benchmark is kept. A stored baseline is not used: timings from another
# machine are not comparable.
#
# Prints a table of B/A ratios and exits with status 1 if any ratio exceeds
# THRESHOLD (default 1.2).
#
#     julia benchmark/compare.jl rev:release-1.13 path:.

const REPOSITORY = "https://github.com/JuliaMath/DoubleFloats.jl"

function worker(output)
    include(joinpath(@__DIR__, "benchmarks.jl"))
    Base.invokelatest() do
        results = run(SUITE; seconds = 0.4, samples = 400, evals = 1)
        open(output, "w") do io
            for (path, trial) in BenchmarkTools.leaves(results)
                println(io, join(path, " / "), '\t', minimum(trial).time)
            end
        end
    end
end

function addcommand(spec)
    if startswith(spec, "path:")
        return "Pkg.develop(path = $(repr(abspath(spec[6:end]))); io = devnull)"
    elseif startswith(spec, "rev:")
        return "Pkg.add(url = $(repr(REPOSITORY)), rev = $(repr(spec[5:end])); io = devnull)"
    else
        return "Pkg.add(name = \"DoubleFloats\", version = $(repr(spec)); io = devnull)"
    end
end

function environment(spec)
    env = mktempdir()
    run(
        `$(Base.julia_cmd()) --project=$env -e "using Pkg; $(addcommand(spec)); Pkg.add(\"BenchmarkTools\"; io = devnull)"`,
    )
    return env
end

function measure!(best, env)
    output = tempname()
    run(`$(Base.julia_cmd()) --project=$env $(@__FILE__) --worker $output`)
    for line in eachline(output)
        key, time = split(line, '\t')
        best[key] = min(get(best, key, Inf), parse(Float64, time))
    end
    return best
end

function driver(a, b, threshold, rounds)
    enva, envb = environment(a), environment(b)
    besta, bestb = Dict{String,Float64}(), Dict{String,Float64}()
    for _ in 1:rounds
        measure!(besta, enva)
        measure!(bestb, envb)
    end
    println(
        "A: `",
        a,
        "`. B: `",
        b,
        "`. Julia ",
        VERSION,
        ", ",
        Sys.CPU_NAME,
        ". Minimum of ",
        rounds,
        " rounds; times are for one pass over each benchmark's inputs.\n",
    )
    println("| Benchmark | A (μs) | B (μs) | B/A | |")
    println("|:--|--:|--:|--:|:--|")
    slower = String[]
    for key in sort!(collect(intersect(keys(besta), keys(bestb))))
        ratio = bestb[key] / besta[key]
        mark = ratio > threshold ? "slower" : ratio < 1 / threshold ? "faster" : ""
        ratio > threshold && push!(slower, key)
        println(
            "| ",
            key,
            " | ",
            round(besta[key] / 1000; digits = 2),
            " | ",
            round(bestb[key] / 1000; digits = 2),
            " | ",
            round(ratio; digits = 2),
            " | ",
            mark,
            " |",
        )
    end
    for key in sort!(collect(symdiff(keys(besta), keys(bestb))))
        println(
            "| ",
            key,
            " | ",
            haskey(besta, key) ? "present" : "absent",
            " | ",
            haskey(bestb, key) ? "present" : "absent",
            " | | |",
        )
    end
    println("\n", length(slower), " benchmarks slower than ", threshold, " times A.")
    isempty(slower) || exit(1)
end

if length(ARGS) == 2 && ARGS[1] == "--worker"
    worker(ARGS[2])
elseif length(ARGS) >= 2
    driver(
        ARGS[1],
        ARGS[2],
        length(ARGS) >= 3 ? parse(Float64, ARGS[3]) : 1.2,
        length(ARGS) >= 4 ? parse(Int, ARGS[4]) : 2,
    )
else
    println("usage: julia benchmark/compare.jl A B [THRESHOLD] [ROUNDS]")
end
