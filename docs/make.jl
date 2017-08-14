using Documenter, UEM

makedocs()

deploydocs(
    deps   = Deps.pip("mkdocs", "python-markdown-math"),
    repo = "github.com/JuliaEconometrics/UEM.jl.git",
    julia  = "0.6"
)
