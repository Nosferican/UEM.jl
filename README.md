# UEM

[![Build Status](https://travis-ci.org/JuliaEconometrics/UEM.jl.svg?branch=master)](https://travis-ci.org/JuliaEconometrics/UEM.jl)

[![codecov](https://codecov.io/gh/JuliaEconometrics/UEM.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/JuliaEconometrics/UEM.jl)

[![](https://img.shields.io/badge/docs-stable-blue.svg)](https://JuliaEconometrics.github.io/UEM.jl/stable)
[![](https://img.shields.io/badge/docs-latest-blue.svg)](https://JuliaEconometrics.github.io/UEM.jl/latest)

# Instructions for those unfamiliar with Julia

1. Install [Julia (v0.06)](https://julialang.org/downloads/)
2. Install [Anaconda (v3.6)](https://www.continuum.io/downloads)
3. Run Julia and add the `IJulia` package: `Pkg.add("IJulia")`
4. Open Anaconda and run `Jupyter`
5. Download a copy of the Notebook Tutorial and open it in a Jupyter Notebook.

# Tutorial
1. Follow the instructions in the *Notebook Tutorial.ipnb* in the repository.
2. Play around with the different options.

# Stage of Development

## Current Progress

1. One-way and Two-ways Unobserved Effects Model
2. Available Estimators:
  - Pooling OLS
  - First-Difference
  - Between
  - Fixed Effects (cross-sectional)
  - Random Effects (Swamy-Arora harmonic mean) [Currently implemented for One-Way Error Component Models]
  - Pooling 2SLS
  - First-Difference 2SLS
  - Between 2SLS
  - Fixed Effects 2SLS
  - Random Effects 2SLS

3. Robust Variance-Covariance Estimators:
  - OLS
  - HC0
  - HC1
  - HC2
  - HC3
  - HC4
  - Clustered at Panel ID
  - Clustered at Temporal ID
  - Two-Ways Clustered at Panel and Temporal Dimensions
4. Methods for `StatsBase.RegressionModel`
5. Added diagnostic tests for consistency of Random Effect, VIF, and Hettest.

## Future Development

1. Documentation
2. Hausman-Taylor Estimator
3. Integration with `CovarianceMatrices.jl` for access to HAC variance-covariance estimators
4. Add poolability test (Roy-Zellner)

## For questions, feedback, reporting bugs please open an issue.
