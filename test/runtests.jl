Pkg.add("RDatasets")
Pkg.add("Distributions")

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
# First-Difference - HC1 - Crime (Values from Stata 13 output)
Crime = dataset("plm", "Crime")
fm = @formula(CRMRTE ~ PrBarr + PrbConv + TaxPC)
model = uem(:FD, fm, Crime)
Wald, F, p = UEM.get_Wald_test(model, VCE = :HC1)
@test nobs(model) == 540
@test get(model, :Varlist) == ["(Intercept)", "PrBarr", "PrbConv", "TaxPC"]
@test isapprox(coef(model),
    [0.000041, -0.0055141, -0.0004468, 0.0000289];
    atol = 1e-4)
@test isapprox(stderr(model, variant = :HC1),
    [0.0003904, 0.0034763, 0.0004631, 0.0000332];
    atol = 1e-4)
@test dof_residual(model) == 536
@test isapprox(r2(model), 0.0159; atol = 1e-4)
@test isapprox(Wald, 0.90; atol = 1e-2)
@test params(F) == (3, 536)
@test isapprox(p, 0.4404; atol = 1e-4)
@test all(isapprox.(confint(model, VCE = :HC1),
        ([-0.000726, -0.0123429, -0.0013565, -0.0000364],
            [0.000808, 0.0013147, 0.000463, 0.0000942]);
        atol = 1e-4))
