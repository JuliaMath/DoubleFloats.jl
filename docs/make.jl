using Documenter, DoubleFloats

makedocs(
    modules = [DoubleFloats],
    sitename = "DoubleFloats.jl",
    authors = "Jeffrey Sarnoff, Simon Byrne, Sascha Timme, and other contributors",
    pages = Any[
        "Overview" => "overview.md",
        "Characteristics" => "characteristics.md",
        "Capabilities" => "capabilities.md",
        "Appropriate Uses" => "appropriate.md",
        "Refs" => "references.md"
    ]
)

deploydocs(
    repo = "github.com/JuliaMath/DoubleFloats.jl.git",
    target = "build"
)
