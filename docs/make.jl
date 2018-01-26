using DoubleFloats, Documenter

makedocs(
    modules = [DoubleFloats],
    clean = false,
    format = :html,
    sitename = "DoubleFloats.jl",
    authors = "Jeffrey Sarnoff, Simon Byrne, Sascha Timme, and other contributors",
    pages = [
        "Home" => "index.md",
        "Refs" => "references.md"
    ],
)

deploydocs(
    repo = "github.com/JuliaMath/DoubleFloats.jl.git",
    target = "build",
    deps = nothing,
    make = nothing,
)
