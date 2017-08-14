using Documenter, UEM

<<<<<<< HEAD
makedocs(
    ...,
    format = :html,
    sitename = "Unobserved Effects Models"
)

deploydocs(
    repo   = "https://github.com/JuliaEconometrics/UEM.jl.git",
    target = "build",
    deps   = nothing,
    make   = nothing
=======
makedocs()

deploydocs(
    deps = Deps.pip("pygments", "mkdocs", "python-markdown-math"),
    repo = "github.com/JuliaEconometrics/UEM.jl.git",
    julia  = "0.6"
>>>>>>> master
)
