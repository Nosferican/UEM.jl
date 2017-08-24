Pkg.add("RDatasets")
using Documenter, UEM
using RDatasets

makedocs(
    # format = :html,
    sitename = "UEM.jl",
    pages = [
        "index.md",
        "GettingStarted.md",
        "ModelAPI.md",
        "Diagnostics.md",
        "Examples.md",
        "References.md"
    ]
)

deploydocs(
    deps = Deps.pip("pygments", "mkdocs", "python-markdown-math"),
    repo = "github.com/JuliaEconometrics/UEM.jl.git",
    julia  = "0.6"
)
