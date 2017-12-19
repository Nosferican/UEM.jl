__precompile__()
	module UEM
	import Base
	import StatsBase
	import Distributions
	import DataFrames
	import RowEchelon
	import StatsModels

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
