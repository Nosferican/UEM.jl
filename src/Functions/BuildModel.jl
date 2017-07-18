function build_model(estimator::Estimators, Effect::Vector{UnitRange{Int64}}, TID::Vector{UnitRange{Int64}}, X::Matrix{Float64}, y::Vector{Float64}, varlist::Vector{String}, Categorical::Vector{Bool}, Intercept::Bool; short::Bool = false)
	N = size(X, 1)
	X = transform(estimator, Effect, X, Categorical, Intercept)
	X, LinearIndependent = get_fullrank(X)
	X = ModelValues_X(X)
	y = transform(estimator, Effect, y)
	y = ModelValues_y(y)
	nobs = ModelValues_nobs(y)
	Effect = transform(estimator, Effect)
	PID = ModelValues_PanelID(Effect)
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
			return MRSS, T, nobs, N, n, Effect, TID
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

function build_model(estimator::RE, Effect::Vector{UnitRange{Int64}}, TID::Vector{UnitRange{Int64}}, X::Matrix{Float64}, y::Vector{Float64}, varlist::Vector{String}, Categorical::Vector{Bool}, Intercept::Bool)
	MRSS_be, X̄, ȳ = build_model(BE(), Effect, TID, X, y, varlist, Categorical, Intercept, short = true)
	MRSS_fe, T, nobs, N, n, Effect, TID = build_model(FE(), Effect, TID, X, y, varlist, Categorical, Intercept, short = true)
	idiosyncratic = ModelValues_Idiosyncratic(get(MRSS_fe))
	T = ModelValues_T(T)
	individual = ModelValues_Individual(MRSS_be, idiosyncratic, T)
	Effect = ModelValues_PanelID(Effect)
	θ = ModelValues_θ(idiosyncratic, individual, Effect)
	Lens = length.(get(Effect))
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
	return Effect, TID, X, Bread, y, β, varlist, ŷ, û, nobs, N, n, T, mdf, rdf, RSS, MRSS, individual, idiosyncratic, θ
end
