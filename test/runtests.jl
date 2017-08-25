Pkg.add("RDatasets")

using UEM
using Base.Test
using RDatasets
using Distributions
using StatsBase

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
pool!(Crime, :Region)
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
# Fixed Effects - PID - Crime (Values from Stata 13 output)
fm = @formula(CRMRTE ~ PrBarr + PrbConv + TaxPC + Region)
model = uem(:FE, fm, Crime)
Wald, F, p = UEM.get_Wald_test(model, VCE = :PID)
@test nobs(model) == 630
@test get(model, :Varlist) == ["(Intercept)", "PrBarr", "PrbConv", "TaxPC"]
@test isapprox(coef(model), [0.029926, -0.0019807, -0.0000179, 0.0000755]; atol = 1e-4)
@test isapprox(stderr(model, variant = :PID),
    [0.002433, 0.0024184, 0.0001945, 0.0000734];
    atol = 1e-4)
@test isapprox(r2(model), 0.0083; atol = 1e-4)
@test isapprox(Wald, 0.93; atol = 1e-2)
@test params(F) == (3, 89)
@test isapprox(p, 0.4292; atol = 1e-4)
@test all(isapprox.(confint(model, VCE = :PID),
        ([0.0250917, -0.006786, -0.0004044, -0.0000704],
            [0.0347604, 0.0028245, 0.0003685, 0.0002214]);
        atol = 1e-4))
# Random Effects - PID - Crime (Values from Stata 13 output)
contrasts = Dict([
    (:Region,DataFrames.ContrastsMatrix(DummyCoding(), ["central","other","west"]))])
model = uem(:RE, fm, Crime, contrasts = contrasts)
Wald, F, p = UEM.get_Wald_test(model, VCE = :PID)
@test StatsBase.nobs(model) == 630
n = StatsBase.nobs(model)
@test get(model, :Varlist) == ["(Intercept)", "PrBarr", "PrbConv", "TaxPC",
    "Region: other", "Region: west"]
@test isapprox(coef(model),
    [0.0344377, -0.0052348, -0.0001242, 0.0000923, -0.0009603, -.0153131];
    atol = 1e-4)
@test isapprox(stderr(model, variant = :PID),
    [0.0038839, 0.0028668, 0.0002135, 0.0000761, 0.0040262, 0.0034752];
    atol = 1e-4)
@test isapprox(r2(model), 0.045523; atol = 1e-3) # This value is from R's PLM
R2 = StatsBase.r2(model)
@test isapprox(Wald * first(params(F)), 44.48; atol = 1e-2)
@test params(F) == (5, 89)
@test isapprox(p, 0.0000; atol = 1e-4)
@test all(isapprox.(confint(model, VCE = :PID),
        ([0.0268254, -0.0108536, -0.0005427, -0.0000569, -0.0088515, -0.0221245],
            [0.0420499, 0.000384, 0.0002943, 0.0002415, 0.006931, -0.0085017]);
        atol = 1e-4))
@test StatsBase.dof(model) == 5
k = StatsBase.dof(model)
@test StatsBase.adjr2(model) == 1 - (1 - (1 - R2) * (n - 1) / (n - k))
@test StatsBase.deviance(model) ≈ (StatsBase.residuals(model)' * StatsBase.residuals(model)) / StatsBase.dof_residual(model)
# G2SLS - OLS - Crime (Values from Stata 13 output)
fm = @formula(CRMRTE ~ PrBarr + PrbConv)
iv = @formula(Density + AvgSen ~ PrbPris + PctYMle)
model = uem(:RE, fm, iv, Crime, contrasts = contrasts)
Wald, F, p = UEM.get_Wald_test(model)
@test nobs(model) == 630
@test get(model, :Varlist) == ["(Intercept)", "PrBarr", "PrbConv", "Density", "AvgSen"]
@test isapprox(coef(model),
    [0.1275473, -0.0132396, -0.0003773, -0.0617464, -0.0006752];
    atol = 1e-4)
@test isapprox(stderr(model),
    [0.3089493, 0.0312082, 0.0009476, 0.1800369, 0.0068559];
    atol = 1e-4)
@test isapprox(Wald, 0.15; atol = 1e-2)
@test params(F) == (4, 625) # Stata has 626, but R's PLM has 625
@test isapprox(p, 0.9614; atol = 1e-4)
@test all(isapprox.(confint(model),
        ([-0.4791553, -0.0745251, -0.002238, -0.4152958, -0.0141386],
            [0.7342499, 0.0480459, 0.0014835, 0.291803, 0.0127881]);
        atol = 1e-4))
