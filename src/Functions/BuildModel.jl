function build_model(estimator::Estimators, PID::Vector{UnitRange{Int64}}, TID::Vector{UnitRange{Int64}}, Effect::Symbol, X::Matrix{Float64}, y::Vector{Float64}, varlist::Vector{String}, Categorical::Vector{Bool}, Intercept::Bool; short::Bool = false)
	N = size(X, 1)
	@assert Effect in [:Panel, :Temporal, :TwoWays] "Effect must be either:\n
	Panel, Temporal or TwoWays"
	if Effect == :Panel
		X = transform(estimator, PID, X, Categorical, Intercept)
	elseif Effect == :Temporal
		X = transform(estimator, TID, X, Categorical, Intercept)
	elseif Effect == :TwoWays
		X = transform(estimator, vcat(PID, TID), X, Categorical, Intercept)
	end
	X, LinearIndependent = get_fullrank(X)
	X = ModelValues_X(X)
	if Effect == :Panel
		y = transform(estimator, PID, y)
	elseif Effect == :Temporal
		y = transform(estimator, TID, y)
	elseif Effect == :TwoWays
		y = transform(estimator, vcat(PID, TID), y)
	end
	y = ModelValues_y(y)
	nobs = ModelValues_nobs(y)
	PID = transform(estimator, PID)
	PID = ModelValues_PanelID(PID)
	T = ModelValues_T(PID)
	n = ModelValues_n(PID)
	Bread = ModelValues_Bread(X)
	β = ModelValues_β(X, Bread, y)
	ŷ = ModelValues_ŷ(X, β)
	û = ModelValues_û(y, ŷ)
	mdf = length(get(β)) - Intercept
	if isa(estimator, FE)
		mdf += get(n) - 1
	end
	mdf = ModelValues_dof(mdf)
	rdf = ModelValues_rdf(get(nobs) - get(mdf) - Intercept)
	RSS = ModelValues_RSS(û)
	MRSS = ModelValues_MRSS(RSS, rdf)
	if short
		if isa(estimator, BE)
			return MRSS, X, y
		elseif isa(estimator, FE)
			return MRSS, T, nobs, N, n, PID, TID
		end
	end
	TID = transform(estimator, TID)
	varlist = varlist[find(LinearIndependent)]
	varlist = ModelValues_Varlist(varlist)
	idiosyncratic = ModelValues_Idiosyncratic(zero(Float64))
	individual = ModelValues_Individual(MRSS,
								idiosyncratic,
								T)
	θ = ModelValues_θ(idiosyncratic, individual, PID)
	return PID, TID, X, Bread, y, β, varlist, ŷ, û, nobs, N, n, T, mdf, rdf, RSS, MRSS, individual, idiosyncratic, θ
end

function build_model(estimator::RE, PID::Vector{UnitRange{Int64}}, TID::Vector{UnitRange{Int64}}, Effect::Symbol, X::Matrix{Float64}, y::Vector{Float64}, varlist::Vector{String}, Categorical::Vector{Bool}, Intercept::Bool)
	@assert Effect in [:Panel, :Temporal, :TwoWays] "Effect must be either:\n
	Panel, Temporal or TwoWays"
	MRSS_be, X̄, ȳ = build_model(BE(), PID, TID, Effect, X, y, varlist, Categorical, Intercept, short = true)
	MRSS_fe, T, nobs, N, n, Effect, TID = build_model(FE(), PID, TID, Effect, X, y, varlist, Categorical, Intercept, short = true)
	idiosyncratic = ModelValues_Idiosyncratic(get(MRSS_fe))
	T = ModelValues_T(T)
	individual = ModelValues_Individual(MRSS_be, idiosyncratic, T)
	PID = ModelValues_PanelID(PID)
	θ = ModelValues_θ(idiosyncratic, individual, PID)
	Lens = length.(get(PID))
	X = transform(X, X̄, θ, Lens)
	X, LinearIndependent = get_fullrank(X)
	X = ModelValues_X(X)
    y = transform(y, ȳ, θ, Lens)
	varlist = ModelValues_Varlist(varlist[LinearIndependent])
	Bread = ModelValues_Bread(X)
	β = ModelValues_β(X, Bread, y)
	ŷ = ModelValues_ŷ(X, β)
	û = ModelValues_û(y, ŷ)
	mdf = ModelValues_dof(length(get(β)) - Intercept)
	rdf = ModelValues_rdf(get(nobs) - get(mdf) - Intercept)
	RSS = ModelValues_RSS(û)
	MRSS = ModelValues_MRSS(RSS, rdf)
	return PID, TID, X, Bread, y, β, varlist, ŷ, û, nobs, N, n, T, mdf, rdf, RSS, MRSS, individual, idiosyncratic, θ
end
