using UEM
using Base.Test
using RDatasets
using Distributions

# Pooling - OLS - Grunfeld (Values from Stata 13 output)
Grunfeld = dataset("plm","Grunfeld")
fm = @formula(Value ~ Capital + Inv)
model = uem(:PO, fm, Grunfeld)
Wald, F, p = UEM.get_Wald_test(model)
@test get(model, :Varlist) == ["(Intercept)", "Capital", "Inv"]
@test isapprox(coef(model), [410.8156, -0.6152727, 5.759807]; atol = 1e-4)
@test isapprox(stderr(model), [64.14189, 0.2094979, 0.2908613]; atol = 1e-4)
@test dof_residual(model) == 197
@test isapprox(r2(model), 0.7455; atol = 1e-4)
@test isapprox(Wald, 288.50; atol = 1e-2)
@test params(F) == (2, 197)
@test isapprox(p, 0.0000; atol = 1e-4)
@test all(isapprox.(confint(model),
        ([284.3227, -1.028419, 5.186206], [537.3084, -0.2021263, 6.333409]);
        atol = 1e-4))
