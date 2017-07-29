abstract type UnobservedEffectsModel <: StatsBase.RegressionModel end

struct UnobservedEffectsModelExogenous <: UnobservedEffectsModel
	model_stats::Dict{Symbol, ModelValues}
end
function uem(estimator::Symbol, fm::DataFrames.Formula, df::DataFrames.DataFrame; PID::Symbol = names(df)[1], TID::Symbol = names(df)[2], contrasts = Dict{Symbol, DataFrames.ContrastsMatrix}(),
	effect::String = "Panel")
	estimator = getEstimator(estimator)
	Terms = DataFrames.Terms(fm)
	Intercept = getfield(Terms, :intercept)
	rhs = DataFrames.allvars(getfield(fm, :rhs))
	df, PID, TID = PreModelFrame(fm, df, PID, TID)
	mf = DataFrames.ModelFrame(fm, df, contrasts = contrasts)
	varlist = DataFrames.coefnames(mf)
	X = getfield(DataFrames.ModelMatrix(mf), :m)
	y = Vector{Float64}(df[fm.lhs])
	if Intercept
		Categorical = Vector{Bool}([false])
	else
		Categorical = Vector{Bool}()
	end
	for idx in eachindex(rhs)
		tmp = DataFrames.is_categorical(df[rhs[idx]])
		if tmp
			tmp = repeat([true], inner = length(unique(df[rhs[idx]])) - 1)
		end
		for each in tmp
			push!(Categorical, each)
		end
	end
	PID, TID, X, Bread, y, β, varlist, ŷ, û, nobs, N, n, T, mdf, rdf, RSS, MRSS, individual, idiosyncratic, θ =
		build_model(estimator, PID, TID, Effect, X, y, varlist, Categorical, Intercept)
	R² = ModelValues_R²(y, RSS)
	N = ModelValues_N(N)
	TID = ModelValues_TemporalID(TID)
	estimator = ModelValues_Estimator(estimator)
	Intercept = ModelValues_Intercept(Intercept)
	fm = ModelValues_Formula(fm)
	Effect = ModelValues_Effect(Effect)
	chk = [(:X, X), (:y, y), (:Bread, Bread), (:β, β), (:ŷ, ŷ), (:û, û), (:RSS, RSS), (:mdf, mdf), (:rdf, rdf), (:MRSS, MRSS), (:R², R²), (:nobs, nobs), (:N, N), (:n, n), (:Formula, fm), (:Estimator, estimator), (:Varlist, varlist), (:PID, PID), (:TID, TID), (:Effect, Effect), (:idiosyncratic, idiosyncratic), (:individual, individual), (:θ, θ), (:Intercept, Intercept), (:T, T)]
	# for each in chk
	# 	println(first(each), typeof(last(each)))
	# end
	model_stats = Dict{Symbol, ModelValues}(chk)
	UnobservedEffectsModelExogenous(model_stats)
end
