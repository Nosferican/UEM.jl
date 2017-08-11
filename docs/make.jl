using Documenter, UEM

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
)
