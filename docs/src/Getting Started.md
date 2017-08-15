# Getting Started

## Installation

During the Beta test stage the package can be installed using:
```julia
Pkg.clone("https://github.com/JuliaEconometrics/UEM.jl.git")
```

Once it is released you it may be installed using:
```julia
Pkg.add("UEM")
```

Once installed it can be loaded using as any other Julian package
```@example Tutorial
using UEM
```

## A Dataset

This package assumes tabular data which is enabled in Julia through the `DataFrames` package. For example

```@example Tutorial
using DataFrames
using RDatasets # Not required for actual usage, but it provides some data sets
df = dataset("plm", "Crime") # Loads the Crime data set from the R {plm} package
pool!(df, [:Region, :SMSA]) # String variables must be coded as categorical
```

## Formulae Language

The formula language allows to specify the econometric model

```@example Tutorial
fm = @formula(CRMRTE ~ PrbConv + PrBarr)
iv = @formula(Density + WSer ~ PctYMle + WFed)
```

The `fm` formula describes the response variable and exogenous explanatory variables. The `iv` formula has the endogenous variables on the left-hand side and the additional instruments on the right-hand side.

## Creating an unobserved effects model

### Estimators

- Pooling Ordinary Least Squares (`:PO`)
- First-Difference (`:FD`)
- Between (`:BE`)
- Fixed Effects (`:FE`)
- Random Effects (`:RE`)

The First-Difference estimator handles categorical variables by using the value at that period.

The Random Effects model uses the Swamy-Arora error component estimator with the harmonic mean variant.

### Effects

- Cross-sectional (`:Panel`)
- Temporal (`:Temporal`)
- Two-Ways (`:TwoWays`)

The default value is cross-sectional, but other options are available through the keyword argument `effect::Symbol`

### Panel and Temporal ID indicators

The code assumes the dataframe contains the panel ID and temporal ID variables in the first two columns. If this is not the case, one can indicate which variables to use with keyword arguments.

- `PID::Symbol = :PanelID`
- `TID::Symbol = :TemporalID`

where the symbols are the variable names in the dataframe.

### Exogenous Models

An exogenous model can be requested using:
```julia
model = uem(estimator, fm, df)
```

### Endogenous Models

```julia
uem(estimator, fm, iv, df)
```

## Regression Results

To request the regression results of a model one can use:
```julia
coeftable(model)
```

### Variance-Covariance Estimators

In order to request robust covariance estimators one can specify the desired estimator:
- OLS Variance-covariance estimator (`:OLS`)
- HC0 Variance-covariance estimator (`:HC0`)
- HC1 Variance-covariance estimator (`:HC1`)
- HC2 Variance-covariance estimator (`:HC2`)
- HC3 Variance-covariance estimator (`:HC3`)
- HC4 Variance-covariance estimator (`:HC4`)
- Clustered at Panel ID Variance-covariance estimator (:PID)
- Clustered at Temporal ID Variance-covariance estimator (:TID)
- Clustered at Panel and Temporal Dimensions Variance-covariance estimator (:PTID)

In order to use the chosen estimator with `coeftable` one can pass it as a keyword argument. For example,

```@repl Tutorial
using DataFrames, StatsBase, RDatasets, UEM # hide
df = dataset("plm", "Crime") # hide
pool!(df, [:Region, :SMSA]) # hide
fm = @formula(CRMRTE ~ PrbConv + PrBarr) # hide
estimator = :RE # hide
model = uem(estimator, fm, df) # hide
coeftable(model)
```
