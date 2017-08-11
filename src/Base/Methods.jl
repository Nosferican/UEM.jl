function Base.get(obj::UnobservedEffectsModel, value::Symbol)
	model_stats = getfield(obj, :model_stats)
	if !(value in keys(model_stats))
		@printf "Bad call is: %s" value
	end
	@assert value in keys(model_stats) "The requested statistic is not available."
	Statistic = model_stats[value]
	get(Statistic)
end
function Base.get(obj::ModelValues)
	getfield(obj, :value)
end
Base.show(io::IO, obj::UEM.UnobservedEffectsModel) = print(io, "Model Summary Available with `coeftable(model)`\n")

### Additional
"""
	model_matrix(obj::UEM.UnobservedEffectsModel)
	
	Returns: The design matrix (`Matrix{Float64}`) used in the regression model.

Source: UEM
"""
function model_matrix(obj::UEM.UnobservedEffectsModel)
	get(obj, :X)
end
