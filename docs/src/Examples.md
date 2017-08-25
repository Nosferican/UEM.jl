# Examples

- Set up

```@example Tutorial
using DataFrames, RDatasets, UEM
df = dataset("plm", "Crime")
pool!(df, [:Region, :SMSA])
fm = @formula(CRMRTE ~ PrbConv + PrBarr + Region)
iv = @formula(Density + WSer ~ PctYMle + WFed)
print() # hide
```

- Pooling OLS model with OLS Variance-Covariance Estimator

```@example Tutorial
model = uem(:PO, fm, df)
coeftable(model)
```

- First-Difference model with HC1 Variance-Covariance Estimator

```@example Tutorial
model = uem(:FD, fm, df)
coeftable(model, VCE = :HC1)
```

- Fixed Effects Model with Panel Effects and Clustering by PanelID

```@example Tutorial
model = uem(:FE, fm, df)
coeftable(model, VCE = :PID)
```

- Fixed Effects Model with Temporal Effects and Clustering by Period

```@example Tutorial
model = uem(:FE, fm, df, Effect = :Temporal)
coeftable(model, VCE = :TID)
```

- Fitting a Two-Ways Effect Fixed Effects with Two-Ways Clustering

```@example Tutorial
model = uem(:FE, fm, df, Effect = :TwoWays)
coeftable(model, VCE = :PTID)
```

- Fitting a Random Effects Model and Clustering by PanelID

```@example Tutorial
model = uem(:RE, fm, df)
coeftable(model, VCE = :PID)
```

- Fitting a P2SLS with OLS VCE

```@example Tutorial
model = uem(:PO, fm, iv, df)
coeftable(model)
```

- Fitting a BEIV estimator

```@example Tutorial
model = uem(:BE, fm, iv, df)
coeftable(model)
```

- Fitting a FEIV estimator and Clustering by Panel

```@example Tutorial
model = uem(:FD, fm, iv, df)
coeftable(model, VCE = :PID)
```

- Fitting a REIV estimator and Clustering by Panel

```@example Tutorial
model = uem(:FE, fm, iv, df)
coeftable(model, VCE = :PID)
```

- Consistency of Random Effects Model

```@example Tutorial
fe_or_re(fm, iv, df)
```
