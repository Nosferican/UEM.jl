"""
	fe_or_refe_or_re(fm::StatsModels.Formula,
		df::DataFrames.DataFrame;
		PID::Symbol = names(df)[1],
		TID::Symbol = names(df)[2],
		contrasts = Dict{Symbol, StatsModels.ContrastsMatrix}())

Print the Esarey and Jaffe (2017) Direct Test for Consistency of Random Effects Model.
"""
function fe_or_re(fm::StatsModels.Formula, df::DataFrames.DataFrame; PID::Symbol = names(df)[1], TID::Symbol = names(df)[2], contrasts = Dict{Symbol, StatsModels.ContrastsMatrix}())
	Between = uem(:BE, fm, df, PID = PID, TID = TID, contrasts = contrasts)
	FixedEffects = uem(:FE, fm, df, PID = PID, TID = TID, contrasts = contrasts)
	βfe = StatsBase.coef(FixedEffects)
	ybe = StatsBase.model_response(Between)
	Xbe = get(Between, :X)
	Xbe = Xbe[:,map(elem -> elem in get(FixedEffects, :Varlist), get(Between, :Varlist))]
	cᵢ = ybe - Xbe * βfe
	Bread = inv(cholfact(Xbe' * Xbe))
	β = Bread * Xbe' * ybe
	ŷ = Xbe * β
	û = cᵢ - ŷ
	mdf = length(β) - 1
	rdf = (reduce(-,size(Xbe)) + 1)
	RSS = sum(û.^2)
	MRSS = sum(û.^2) / rdf
	MESS = sum((ŷ - mean(cᵢ)).^2) / mdf
	F = MESS / MRSS
	F_dist = Distributions.FDist(mdf, rdf)
	F_value = Distributions.ccdf(F_dist, F)
	@printf "Esarey and Jaffe (2017) Direct Test for Consistency of Random Effects Model\n
	F(%.0f, %.0f) = %.2f\n
	Prob > F = %.4f\n" mdf rdf F F_value
end
function fe_or_re(fm::StatsModels.Formula, iv::StatsModels.Formula, df::DataFrames.DataFrame; PID::Symbol = names(df)[1], TID::Symbol = names(df)[2], contrasts = Dict{Symbol, StatsModels.ContrastsMatrix}())
	Between = uem(:BE, fm, iv, df, PID = PID, TID = TID, contrasts = contrasts)
	FixedEffects = uem(:FE, fm, iv, df, PID = PID, TID = TID, contrasts = contrasts)
	βfe = StatsBase.coef(FixedEffects)
	ybe = StatsBase.model_response(Between)
	Xbe = get(Between, :X)
	Xbe = Xbe[:,map(elem -> elem in get(FixedEffects, :Varlist), get(Between, :Varlist))]
	cᵢ = ybe - Xbe * βfe
	Bread = inv(cholfact(Xbe' * Xbe))
	β = Bread * Xbe' * ybe
	ŷ = Xbe * β
	û = cᵢ - ŷ
	mdf = length(β) - 1
	rdf = (reduce(-,size(Xbe)) + 1)
	RSS = sum(û.^2)
	MRSS = sum(û.^2) / rdf
	MESS = sum((ŷ - mean(cᵢ)).^2) / mdf
	F = MESS / MRSS
	F_dist = Distributions.FDist(mdf, rdf)
	F_value = Distributions.ccdf(F_dist, F)
	@printf "Esarey and Jaffe (2017) Direct Test for Consistency of Random Effects Model\n
	F(%.0f, %.0f) = %.2f\n
	Prob > F = %.4f\n" mdf rdf F F_value
end
