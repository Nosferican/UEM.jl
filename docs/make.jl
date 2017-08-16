using Documenter, UEM

makedocs(
    sitename = "UEM.jl",
    pages = [
        "index.md",
        "GettingStarted.md",
        "ModelAPI.md",
        "Diagnostics.md",
        "AdditionalFunctions.md",
        "Methodology.md",
        "References.md"
    ]
)

deploydocs(
    deps = Deps.pip("pygments", "mkdocs", "python-markdown-math"),
    repo = "github.com/JuliaEconometrics/UEM.jl.git",
    julia  = "0.6"
)
