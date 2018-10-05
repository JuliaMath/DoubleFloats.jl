using Documenter, DoubleFloats

makedocs(
    modules = [DoubleFloats],
    clean = false,
    format = :html,
    sitename = "DoubleFloats.jl",
    authors = "Jeffrey Sarnoff, Simon Byrne, Sascha Timme, and other contributors",
    pages = [
        "Home" => "index.md",
        "Overview" => "appropriate.md",
        "Names" => "naming.md",
        "Capabilities" => "capabilities.md",
        "Refs" => "references.md"
    ],
)

deploydocs(
    julia = "1.0",
    repo = "github.com/JuliaMath/DoubleFloats.jl.git"
)
