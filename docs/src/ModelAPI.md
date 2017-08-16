# Model API

## *StatsBase.jl* Abstract Types

These methods are implemented for the various abstract types provided by the StatsBase package. If the implementation differs in any way with the standard definition in the StatsBase documentation it will be documented in this section. For the method definitions see the StatsBase documentation [here](https://juliastats.github.io/StatsBase.jl/latest/statmodels.html).

###  Inheritance from `StatsBase.StatisticalModel`

- `adjr2`
- `aic`
- `aicc`
- `bic`
- `coef`
- `coeftable`
- `confint`
- `deviance`
- `dof`
- `loglikelihood`
- `nobs`
- `nulldeviance`
- `r2`
- `stderr`
- `vcov`

### Inheritance from `StatsBase.RegressionModel`

- `dof_residual`
- `fitted`
- `model_response`
- `predict`
- `residuals`

### Additional Notes

The method `r2` is only implemented for exogenous models as it is not valid for instrumental variable estimators.

## Additional Methods for Unobserved Effects Model

- Design Matrix
```julia
model_matrix(obj::UnobservedEffectsModel)
```

- The Error Components for Random Effects may be requested through
```julia
get(obj::UnobservedEffectsModel, value::Symbol)
```
where symbols may include: `:idiosyncratic`, `:individual`, and `:θ`.
