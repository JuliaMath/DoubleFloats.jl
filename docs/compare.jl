# Compare two versions of DoubleFloats side by side.
#
#     julia docs/compare.jl [OLD] [NEW]
#
# OLD and NEW each name a version of the package:
#
#     1.13.3            a registered version
#     rev:NAME          a branch, tag, or commit of the GitHub repository
#     path:DIR          a local checkout
#
# The defaults are `1.13.3` and `rev:main`. Each version is installed into
# its own temporary environment and the same expressions are evaluated in
# both, in separate Julia processes. Nothing in the active project changes.
#
# Examples:
#
#     julia docs/compare.jl
#     julia docs/compare.jl 1.13.3 rev:v2.0.0-alpha1
#     julia docs/compare.jl rev:release-1.13 path:.

const REPOSITORY = "https://github.com/JuliaMath/DoubleFloats.jl"

# Each probe is a label and an expression. `using DoubleFloats, Printf` is in
# effect. An expression that throws is reported by the type of its exception.
const PROBES = [
    "Equality and order" => [
        "NaN == NaN"                  => "Double64(NaN) == Double64(NaN)",
        "sort with NaN"               => "Float64.(sort(Double64[1, NaN, 0, -1]))",
        "isless(-0.0, 0.0)"           => "isless(Double64(-0.0), Double64(0.0))",
        "1/3 == 1//3"                 => "Double64(1)/3 == 1//3",
        "Dict lookup by equal key"    => "haskey(Dict(Double64(1)/3 => 1), big(Double64(1)/3))",
        "decompose"                   => "Base.decompose(Double64(1)/3) isa Tuple",
    ],
    "Construction and conversion" => [
        "Double64(2^62 + 1) exact"    => "big(Double64(2^62 + 1)) == 2^62 + 1",
        "Double64(1.0, 1.0) words"    => "HILO(Double64(1.0, 1.0))",
        "Int64(Double64(2.5))"        => "Int64(Double64(2.5))",
        "rationalize(1/3)"            => "rationalize(Double64(1)/3)",
        "tryparse of bad text"        => "tryparse(Double64, \"abc\")",
        "Double32 + Float64"          => "typeof(Double32(1) + 1.0)",
    ],
    "Text" => [
        "string(1/3)"                 => "string(Double64(1)/3)",
        "repr(1/3)"                   => "repr(Double64(1)/3)",
        "repr round trip"             => "eval(Meta.parse(repr(Double64(1)/3))) === Double64(1)/3",
        "string of Double32(1)/3"     => "string(Double32(1)/3)",
        "string round trip, wide"     => "(x = Double64(1.0) + Double64(2.0)^-200; parse(Double64, string(x)) == x)",
        "@sprintf %.25f"              => "@sprintf(\"%.25f\", Double64(1)/3)",
    ],
    "Elementary functions on wide inputs" => [
        "sinpi(1 + 2^-120), true -2.36e-36" => "Float64(sinpi(Double64(1.0) + Double64(2.0)^-120))",
        "acos(1 - 2^-120), true 1.23e-18"   => "Float64(acos(Double64(1.0) - Double64(2.0)^-120))",
        "sinpi near 1, error in units of 2^-104" =>
            "(x = 1 + Double64(1)/3 * 2.0^-40; t = sinpi(big(x)); round(Float64(abs((big(sinpi(x)) - t) / t) * big(2.0)^104), sigdigits = 3))",
    ],
]

function addcommand(spec::AbstractString)
    if startswith(spec, "path:")
        return "Pkg.develop(path = $(repr(abspath(spec[6:end]))); io = devnull)"
    elseif startswith(spec, "rev:")
        return "Pkg.add(url = $(repr(REPOSITORY)), rev = $(repr(spec[5:end])); io = devnull)"
    else
        return "Pkg.add(name = \"DoubleFloats\", version = $(repr(spec)); io = devnull)"
    end
end

const SEPARATOR = '\x1e'

function runnersource()
    io = IOBuffer()
    println(io, "using DoubleFloats, Printf")
    println(io, "setprecision(BigFloat, 512)")
    println(io, "function probe(f)")
    println(io, "    try")
    println(io, "        return repr(f())")
    println(io, "    catch err")
    println(io, "        return string(\"throws \", nameof(typeof(err)))")
    println(io, "    end")
    println(io, "end")
    println(io, "results = String[]")
    for (_, probes) in PROBES, (_, code) in probes
        println(io, "push!(results, probe(() -> begin; ", code, "; end))")
    end
    println(io, "print(join(results, ", repr(SEPARATOR), "))")
    return String(take!(io))
end

function evaluate(spec::AbstractString)
    env = mktempdir()
    julia = Base.julia_cmd()
    run(`$julia --project=$env -e "using Pkg; $(addcommand(spec)); Pkg.add(\"Printf\"; io = devnull)"`)
    runner = joinpath(env, "probes.jl")
    write(runner, runnersource())
    version = readchomp(`$julia --project=$env -e "using DoubleFloats; print(pkgversion(DoubleFloats))"`)
    return version, split(read(`$julia --project=$env $runner`, String), SEPARATOR)
end

clip(s, n = 44) = textwidth(s) <= n ? s : string(first(s, n - 1), '…')
cell(s) = replace(clip(s), '|' => "\\|")

function main(args)
    old = length(args) >= 1 ? args[1] : "1.13.3"
    new = length(args) >= 2 ? args[2] : "rev:main"
    oldversion, oldresults = evaluate(old)
    newversion, newresults = evaluate(new)
    println("Julia ", VERSION, ". Old: `", old, "` (", oldversion, "). New: `", new, "` (", newversion, ").")
    i = 0
    changed = 0
    for (section, probes) in PROBES
        println("\n### ", section, "\n")
        println("| Probe | Old | New | |")
        println("|:--|:--|:--|:--|")
        for (label, _) in probes
            i += 1
            differs = oldresults[i] != newresults[i]
            changed += differs
            println("| ", cell(label), " | `", cell(oldresults[i]), "` | `", cell(newresults[i]), "` | ",
                    differs ? "changed" : "", " |")
        end
    end
    println("\n", changed, " of ", i, " probes differ.")
end

main(ARGS)
