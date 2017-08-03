abstract type ModelValues end
struct ModelValues_Intercept <: ModelValues
	value::Bool
end
struct ModelValues_Effect <: ModelValues
	value::String
end
struct ModelValues_X <: ModelValues
	value::Matrix{Float64}
end
struct ModelValues_Bread <: ModelValues
	value::Matrix{Float64}
	function ModelValues_Bread(X::ModelValues_X)
		X = get(X)
		Bread = inv(cholfact(X' * X))
		new(Bread)
	end
end
struct ModelValues_Varlist <: ModelValues
	value::Vector{String}
end
struct ModelValues_y <: ModelValues
	value::Vector{Float64}
end
struct ModelValues_PanelID <: ModelValues
	value::Vector{Vector{Int64}}
end
struct ModelValues_TemporalID <: ModelValues
	value::Vector{Vector{Int64}}
end
struct ModelValues_nobs <: ModelValues
	value::Int64
	function ModelValues_nobs(y::ModelValues_y)
		new(length(get(y)))
	end
end
struct ModelValues_N <: ModelValues
	value::Int64
	function ModelValues_N(value)
		@assert value >= 0 "Number of observations must be non-negative."
		new(value)
	end
end
struct ModelValues_n <: ModelValues
	value::Int64
	function ModelValues_n(PID::ModelValues_PanelID)
		new(length(get(PID)))
	end
end
struct ModelValues_T <: ModelValues
	value::Tuple{Int64,Float64,Int64}
	function ModelValues_T(PID::ModelValues_PanelID)
		Lens = length.(get(PID))
		new((minimum(Lens), StatsBase.harmmean(Lens), maximum(Lens)))
	end
end
struct ModelValues_dof <: ModelValues
	value::Int64
end
struct ModelValues_rdf <: ModelValues
	value::Int64
end
struct ModelValues_β <: ModelValues
	value::Vector{Float64}
	function ModelValues_β(X::ModelValues_X, Bread::ModelValues_Bread, y::ModelValues_y)
		X = get(X)
		Bread = get(Bread)
		y = get(y)
		β = Bread * X' * y
		new(β)
	end
end
struct ModelValues_ŷ <: ModelValues
	value::Vector{Float64}
	function ModelValues_ŷ(X::ModelValues_X, β::ModelValues_β)
		X = get(X)
		β = get(β)
		ŷ = X * β
		new(ŷ)
	end
end
struct ModelValues_û <: ModelValues
	value::Vector{Float64}
	function ModelValues_û(y::ModelValues_y, ŷ::ModelValues_ŷ)
		y = get(y)
		ŷ = get(ŷ)
		û = y - ŷ
		new(û)
	end
end
struct ModelValues_RSS <: ModelValues
	value::Float64
	function ModelValues_RSS(û::ModelValues_û)
		û = get(û)
		new(û' * û)
	end
end
struct ModelValues_MRSS <: ModelValues
	value::Float64
	function ModelValues_MRSS(RSS::ModelValues_RSS, rdf::ModelValues_rdf)
		RSS = get(RSS)
		rdf = get(rdf)
		MRSS = RSS / rdf
		new(MRSS)
	end
end
struct ModelValues_R² <: ModelValues
	value::Float64
	function ModelValues_R²(y::ModelValues_y, RSS::ModelValues_RSS)
		y = get(y)
		RSS = get(RSS)
		ȳ = mean(y)
		TSS = sum((y - ȳ).^2)
		R² = 1 - RSS / TSS
		@assert (in_closed_unit_interval(R²)) "R² must be ∈ the closed unit interval."
		new(R²)
	end
end
struct ModelValues_Idiosyncratic <: ModelValues
	value::Float64
end
struct ModelValues_Individual <: ModelValues
	value::Float64
	function ModelValues_Individual(MRSS::ModelValues_MRSS,
								Idiosyncratic::ModelValues_Idiosyncratic,
								T::ModelValues_T)
		MRSS = get(MRSS)
		idiosyncratic = get(Idiosyncratic)
		T̄ = get(T)[2]
		individual = max(0, MRSS - idiosyncratic / T̄)
		new(individual)
	end
end
struct ModelValues_θ <: ModelValues
	value::Vector{Float64}
	function ModelValues_θ(Idiosyncratic::ModelValues_Idiosyncratic,
					Individual::ModelValues_Individual,
					PID::ModelValues_PanelID)
		idiosyncratic = get(Idiosyncratic)
		individual = get(Individual)
		Lens = length.(get(PID))
		θ = 1 - sqrt.(idiosyncratic ./ (Lens .* individual .+ idiosyncratic))
		@assert (in_closed_unit_interval(θ)) "Values for θ must be ∈ [0, 1]."
		new(θ)
	end
end
struct ModelValues_Formula <: ModelValues
	value::DataFrames.Formula
end
struct ModelValues_Estimator <: ModelValues
	value::Estimators
end
