using Documenter, DoubleFloats

makedocs(
    modules = [DoubleFloats],
    sitename = "DoubleFloats.jl",
    authors = "Jeffrey Sarnoff, Simon Byrne, Sascha Timme, and other contributors",
    pages = Any[
        "Home" => "index.md",
        "Overview" => "overview.md",
        "Characteristics" => "characteristics.md",
        "Appropriate Use" => "appropriate.md",
        "Names" => "naming.md",
        "Capabilities" => "capabilities.md",
        "Refs" => "references.md"
    ]
)

deploydocs(
    repo = "github.com/JuliaMath/DoubleFloats.jl.git",
    target = "build"
)
