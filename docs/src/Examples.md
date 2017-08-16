# Examples

Set up
```@example Tutorial
using DataFrames, RDatasets, UEM
df = dataset("plm", "Crime")
pool!(df, [:Region, :SMSA])
fm = @formula(CRMRTE ~ PrbConv + PrBarr + Region)
iv = @formula(Density + WSer ~ PctYMle + WFed)
```

1. Requesting a pooling OLS model with OLS Variance-Covariance Estimator
```@example Tutorial
model = uem(:PO, fm, df)
coeftable(model)
```

2. Fitting a first-difference model with HC1 Variance-Covariance Estimator
```@example Tutorial
model = uem(:FD, fm, df)
coeftable(model, VCE = :HC1)
```

3. Fitting a Fixed Effects Model with Panel Effects and Clustering
```@example Tutorial
model = uem(:FE, fm, df)
coeftable(model, VCE = :PID)
```

4. Fitting a Fixed Effects Model with Temporal Effects and Clustering
```@example Tutorial
model = uem(:FE, fm, df, Effect = :Temporal)
coeftable(model, VCE = :Temporal)
```

5. Fitting a Two-Ways Effect Fixed Effects with Two-Ways Clustering
```@example Tutorial
model = uem(:FE, fm, df, Effect = :TwoWays)
coeftable(model, VCE = :PTID)
```

6. Fitting a Random Effects Model with Panel ID VCE
```@example Tutorial
model = uem(:RE, fm, df)
coeftable(model, VCE = :PID)
```

7. Fitting a P2SLS with OLS VCE
```@example Tutorial
model = uem(:PO, fm, iv, df)
coeftable(model)
```

8. Fitting a BEIV estimator
```@example Tutorial
model = uem(:BE, fm, iv, df)
coeftable(model)
```

9. Fitting a FEIV estimator with Panel Clustering VCE
```@example Tutorial
model = uem(:FE, fm, iv, df)
coeftable(model, VCE = :PID)
```

10. Fitting a REIV estimator with HC2 Variance-Covariance Estimator
```@example Tutorial
model = uem(:RE, fm, iv, df)
coeftable(model, VCE = :HC2)
```
