using Documenter, DoubleFloats

# the benchmark and accuracy reports are generated into docs/reports by
# docs/reports/benchmarks.jl and docs/reports/accuracies.jl; copy the
# current versions into the documentation source when they exist
for report in ("benchmark_report.md", "accuracy_report.md")
    src = joinpath(@__DIR__, "reports", report)
    if isfile(src)
        cp(src, joinpath(@__DIR__, "src", report); force = true)
    end
end

makedocs(
    modules = [DoubleFloats],
    sitename = "DoubleFloats.jl",
    authors = "Jeffrey Sarnoff, Simon Byrne, Sascha Timme, and other contributors",
    # Directory-style URLs rely on a web server to resolve `page/` to
    # `page/index.html`.  Use direct HTML links for locally opened builds,
    # while retaining pretty URLs for hosted CI deployments.
    format = Documenter.HTML(prettyurls = get(ENV, "CI", "false") == "true"),
    build = get(ENV, "DOCS_BUILD_DIR", "build"),
    pages = Any[
        "Overview" => "index.md",
        "User Guide" => "userguide.md",
        "Construction" => "construction.md",
        "Characteristics" => "characteristics.md",
        "Show, String, Parse" => "stringshowparse.md",
        "Capabilities" => "capabilities.md",
        "Special Functions" => "special.md",
        "Linear Algebra" => "linearalgebra.md",
        "Random Numbers" => "random.md",
        "Appropriate Uses" => "appropriate.md",
        "Technical Guide" => "technicalguide.md",
        "Adding New Functions" => "addingfunctions.md",
        "Benchmark Report" => "benchmark_report.md",
        "Accuracy Report" => "accuracy_report.md",
        "References" => "references.md"
    ]
)

deploydocs(
    repo = "github.com/JuliaMath/DoubleFloats.jl.git",
    target = "build"
)
