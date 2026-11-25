# List the inputs on which two versions of DoubleFloats return different bits.
#
#     julia test/golden/diff.jl A B [LIMIT]
#
# A and B each name a version: a registered version number, `rev:NAME` for a
# branch, tag, or commit of the GitHub repository, or `path:DIR` for a local
# checkout. For every corpus subject whose checksums differ, up to LIMIT
# (default 5) differing inputs are printed with both results.
#
#     julia test/golden/diff.jl rev:release-1.13 path:.

const REPOSITORY = "https://github.com/JuliaMath/DoubleFloats.jl"

# ---------------------------------------------------------------------------
# Worker mode, run inside the environment of one version.

function describe(x)
    if x isa AbstractFloat && !(x isa Base.IEEEFloat) && !(x isa BigFloat)
        return string("(", repr(HI(x)), ", ", repr(LO(x)), ")")
    elseif x isa Tuple
        return string("(", join(map(describe, x), ", "), ")")
    elseif x isa Complex
        return string(describe(real(x)), " + ", describe(imag(x)), "im")
    elseif x isa AbstractArray
        return string(summary(x))
    else
        return repr(x)
    end
end

function worker(mode, input, output)
    @eval using DoubleFloats
    include(joinpath(@__DIR__, "..", "support", "splitmix.jl"))
    include(joinpath(@__DIR__, "subjects.jl"))
    Base.invokelatest() do
        if mode == "--digests"
            open(output, "w") do io
                for s in subjects()
                    println(io, s.key, '\t', join(digests(s.results()), ' '))
                end
            end
        else
            wanted = Dict{String,Vector{Int}}()
            for line in eachline(input)
                key, blocks = split(line, '\t')
                wanted[key] = parse.(Int, split(blocks, ' '))
            end
            open(output, "w") do io
                for s in subjects()
                    haskey(wanted, s.key) || continue
                    results = s.results()
                    single = length(s.arguments) == 1 && length(results) != 1
                    for block in wanted[s.key]
                        first = (block - 1) * GOLDEN_BLOCK + 1
                        for i in first:min(first + GOLDEN_BLOCK - 1, length(results))
                            bytes = IOBuffer()
                            emit(bytes, results[i])
                            argument = single ? string("element ", i) : describe(s.arguments[i])
                            println(io, s.key, '\t', i, '\t', argument, '\t', bytes2hex(take!(bytes)), '\t',
                                    describe(results[i]))
                        end
                    end
                end
            end
        end
    end
end

# ---------------------------------------------------------------------------
# Driver mode.

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
    run(`$(Base.julia_cmd()) --project=$env -e "using Pkg; $(addcommand(spec))"`)
    return env
end

function call(env, mode, input, output)
    run(`$(Base.julia_cmd()) --project=$env $(@__FILE__) $mode $input $output`)
end

function readdigests(path)
    table = Dict{String,Vector{String}}()
    for line in eachline(path)
        key, values = split(line, '\t')
        table[key] = split(values, ' ')
    end
    return table
end

function driver(a, b, limit)
    enva, envb = environment(a), environment(b)
    work = mktempdir()
    call(enva, "--digests", "-", joinpath(work, "a.digests"))
    call(envb, "--digests", "-", joinpath(work, "b.digests"))
    da, db = readdigests(joinpath(work, "a.digests")), readdigests(joinpath(work, "b.digests"))
    for key in sort!(collect(setdiff(keys(da), keys(db))))
        println("only in A: ", key)
    end
    for key in sort!(collect(setdiff(keys(db), keys(da))))
        println("only in B: ", key)
    end
    wanted = joinpath(work, "wanted")
    count = 0
    open(wanted, "w") do io
        for key in sort!(collect(intersect(keys(da), keys(db))))
            n = max(length(da[key]), length(db[key]))
            blocks = [i for i in 1:n if get(da[key], i, "") != get(db[key], i, "")]
            isempty(blocks) && continue
            count += 1
            println(io, key, '\t', join(blocks, ' '))
        end
    end
    if count == 0
        println("No subject differs between ", a, " and ", b, ".")
        return
    end
    call(enva, "--detail", wanted, joinpath(work, "a.detail"))
    call(envb, "--detail", wanted, joinpath(work, "b.detail"))
    shown = Dict{String,Int}()
    total = Dict{String,Int}()
    for (la, lb) in zip(eachline(joinpath(work, "a.detail")), eachline(joinpath(work, "b.detail")))
        fa, fb = split(la, '\t'), split(lb, '\t')
        fa[4] == fb[4] && continue
        key = fa[1]
        total[key] = get(total, key, 0) + 1
        get(shown, key, 0) >= limit && continue
        shown[key] = get(shown, key, 0) + 1
        shown[key] == 1 && println("\n", key)
        println("  input ", fa[2], ": ", fa[3], "\n    A: ", fa[5], "\n    B: ", fb[5])
    end
    println()
    for key in sort!(collect(keys(total)))
        println(rpad(key, 28), total[key], " inputs differ")
    end
    println(count, " subjects differ between ", a, " and ", b, ".")
end

if length(ARGS) >= 1 && startswith(ARGS[1], "--")
    worker(ARGS[1], ARGS[2], ARGS[3])
elseif length(ARGS) >= 2
    driver(ARGS[1], ARGS[2], length(ARGS) >= 3 ? parse(Int, ARGS[3]) : 5)
else
    println("usage: julia test/golden/diff.jl A B [LIMIT]")
end
