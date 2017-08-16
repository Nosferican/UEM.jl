# Diagnostics

## Multicollinearity

The Variance Inflation Factor (VIF) may be requested through:
```julia
vif(model::UnobservedEffectsModel)
```
This variant is the standard (uncentered) version. The implementation uses the diagonal values of $(A^{\top} A^{\top})^{-1}$ where $A$ is the column-wise Z-score transformed model matrix.

## Heteroscedasticity

The Breusch-Pagan (Breusch and Pagan 1979) / Cook-Weisberg (Cook and Weisberg 1983) test for heteroskedasticity F-test variant (Wooldridge 2013) can be requested through
```julia
hettest(model::UnobservedEffectsModel)
```
The implementation reports the results using the fitted values of all features as explanatory variables on the residuals.

## Consistency of Random Effects Estimator

The Direct Test for Consistency of Random Eects Models (Esarey and Jae 2017) which is an alternative to the Durbin-Wu-Hausman specication test (Durbin 1954; Wu 1973; Hausman 1978) can be requested through
```julia
fe_or_re(fm::DataFrames.Formula, df::DataFrames.DataFrame)
fe_or_re(fm::DataFrames.Formula, iv::DataFrames.Formula, df::DataFrames.DataFrame)
```
which supports the same keyword arguments as `uem`.
