# Diagnostics

## Consistency of Random Effects Estimator

The Direct Test for Consistency of Random Eects Models (Esarey and Jae 2017) which is an alternative to the Durbin-Wu-Hausman specication test (Durbin 1954; Wu 1973; Hausman 1978) can be requested through
```julia
fe_or_re(fm::DataFrames.Formula, df::DataFrames.DataFrame)
fe_or_re(fm::DataFrames.Formula, iv::DataFrames.Formula, df::DataFrames.DataFrame)
```
which supports the same keyword arguments as `uem`. This implementation uses $cᵢ = y_{be} - X_{be} * β_{fe}$ where the analysis limits the set of variables to those common in both models.
