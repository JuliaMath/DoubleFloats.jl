using Documenter, DoubleFloats

makedocs(
    modules = [DoubleFloats],
    sitename = "DoubleFloats.jl",
    authors = "Jeffrey Sarnoff, Simon Byrne, Sascha Timme, and other contributors",
    pages = Any[
        "Overview" => "index.md",
        "Construction" => "construction.md",
        "Characteristics" => "characteristics.md",
        "Show, String, Parse" => "stringshowparse.md",
        "Capabilities" => "capabilities.md",
        "Special Functions" => "special.md",
        "Linear Algebra" => "linearalgebra.md",
        "Random Numbers" => "random.md",
        "Appropriate Uses" => "appropriate.md",
        "References" => "references.md"
    ]
)

deploydocs(
    repo = "github.com/JuliaMath/DoubleFloats.jl.git",
    target = "build"
)
