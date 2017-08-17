__precompile__()
	module UEM
	import Base: get, show
	#import StatsBase: CoefTable, RegressionModel, StatisticalModel, adjr2, coef, coeftable, confint, deviance, dof, dof_residual, fitted, loglikelihood, model_response, nobs, nulldeviance, predict, residuals, r2, stderr, vcov
	import StatsBase
	import Distributions: FDist, Normal, TDist, ccdf, logpdf, params, zscore
	import DataFrames: DataFrames, Formula, ModelFrame, ModelMatrix, allvars, getterms
	import RowEchelon

	for (dir, filename) in [
		("Structs", "Estimators.jl"),
		("Structs", "Values.jl"),
		("Structs", "UEM.jl"),
		("Structs", "VCE.jl"),

		("Base", "Methods.jl"),
		("StatsBase", "Methods.jl"),

		("Functions", "Transformations.jl"),
		("Functions", "BuildModel.jl"),
		("Functions", "TestsViolationAssumptions.jl"),
		("Functions", "WaldTest.jl"),

		("", "Helpers.jl")
		]
		include(joinpath(dir, filename))
	end
	export
    uem,
	fe_or_re,
	model_matrix
end
