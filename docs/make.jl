using Documenter, UEM

makedocs(
    format = :html,
    sitename = "UEM.jl",
    pages = [
        "index.md",
        "GettingStarted.md",
        "ModelAPI.md",
        "Diagnostics.md",
        "References.md"
    ]
)

deploydocs(
    deps = Deps.pip("pygments", "mkdocs", "python-markdown-math"),
    repo = "github.com/JuliaEconometrics/UEM.jl.git",
    julia  = "0.6"
)
