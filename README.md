# UEM

[![Build Status](https://travis-ci.org/Nosferican/UEM.jl.svg?branch=master)](https://travis-ci.org/Nosferican/UEM.jl)

[![Coverage Status](https://coveralls.io/repos/Nosferican/UEM.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/Nosferican/UEM.jl?branch=master)

[![codecov.io](http://codecov.io/github/Nosferican/UEM.jl/coverage.svg?branch=master)](http://codecov.io/github/Nosferican/UEM.jl?branch=master)

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

1. One-way (cross-sectional) Unobserved Effects Model
2. Available Estimators:
  - Pooling OLS
  - First-Difference
  - Between
  - Fixed Effects (cross-sectional)
  - Random Effects (Swamy-Arora harmonic mean)
3. Robust Variance-Covariance Estimators:
  - OLS
  - HC0
  - HC1
  - HC2
  - HC3
  - HC4
  - Clustered at Panel ID
4. Most of the integration with methods for `StatsBase.RegressionModel`

## Future Development

0. Documentation
1. Support for Endogenous models:
  - 2SLS versions for POLS, FD, BE, FE, and RE
  - Hausman-Taylor Estimator
  - Hausman Auxiliary Regression Test
2. Integration with `CovarianceMatrices.jl` for access to HAC variance-covariance estimators
3. Finalize model statistics (AIC, BIC, etc.)
4. Add a suite of tests for heteroscedasticity, multicollinearity, etc.
5. Expand effects to temporal and two-ways for:
  - Fixed Effects
  - Temporal Clustering
  - Two-Ways Clustering

## For questions, feedback, reporting bugs please open an issue.
