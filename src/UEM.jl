__precompile__()
	module UEM
	import Base: get, show
	import StatsBase
	import Distributions
	import DataArrays
	using DataFrames: DataFrames, Formula, ModelFrame, ModelMatrix, allvars, getterms
	import RowEchelon: rref
	import ArraySlices: rows
	import Formatting

	for (dir, filename) in [
		("Structs", "Estimators.jl"),
		("Structs", "Values.jl"),
		("Structs", "UEM.jl"),
		("Structs", "VCE.jl"),

		("Base", "Methods.jl"),
		("StatsBase", "Methods.jl"),

		("Functions", "Transformations.jl"),
		("Functions", "BuildModel.jl"),
		("Functions", "WaldTest.jl"),

		("", "Helpers.jl")
		]
		include(joinpath(dir, filename))
	end
end
