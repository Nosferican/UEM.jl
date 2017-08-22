# UEM

[![License: LGPL v3](https://img.shields.io/badge/License-LGPL%20v3-blue.svg)](https://github.com/JuliaEconometrics/UEM.jl/blob/master/LICENSE.md) [![Project Status](http://www.repostatus.org/badges/latest/wip.svg)](http://www.repostatus.org/#wip) [![Build Status](https://travis-ci.org/JuliaEconometrics/UEM.jl.svg?branch=master)](https://travis-ci.org/JuliaEconometrics/UEM.jl) [![codecov](https://codecov.io/gh/JuliaEconometrics/UEM.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/JuliaEconometrics/UEM.jl)
[![](https://img.shields.io/badge/docs-stable-blue.svg)](https://JuliaEconometrics.github.io/UEM.jl/stable) [![](https://img.shields.io/badge/docs-latest-blue.svg)](https://JuliaEconometrics.github.io/UEM.jl/latest)

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
5. Added diagnostic tests for consistency of Random Effect.

## Future Development

1. Hausman-Taylor Estimator
2. Add poolability test (Roy-Zellner)
3. Integration with `CovarianceMatrices.jl` for access to HAC variance-covariance estimators

## For questions, feedback, reporting bugs please open an issue.
