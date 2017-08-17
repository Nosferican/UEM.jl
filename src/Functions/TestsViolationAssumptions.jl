"""
	hettest(obj::UnobservedEffectsModel)

# Summary
Print the Breusch-Pagan / Cook-Weisberg test for heteroskedasticity F-test version.
"""
function hettest(obj::UnobservedEffectsModel)
	y = StatsBase.residuals(obj).^2
	X = hcat(ones(length(y)), StatsBase.fitted(obj))
	Bread = inv(cholfact(X' * X))
	β = Bread * X' * y
	ŷ = X * β
	û = y - ŷ
	MESS = sum((ŷ - mean(y)).^2)
	RSS = sum(û.^2)
	rdf = length(y) - 2
	MRSS = RSS / rdf
	F = MESS / MRSS
	F_dist = Distributions.FDist(1, rdf)
	F_value = Distributions.ccdf(F_dist, F)
	@printf "Breusch-Pagan / Cook-Weisberg test for heteroskedasticity\n
	Ho: Constant variance\n
	F(1, %.0f) = %.2f\n
	Prob > F = %.4f\n" rdf F F_value
end
"""
	vif(obj::UnobservedEffectsModel)

Return the uncentered Variance Inflation Factor (VIF) by variable and value along with the mean VIF as a `StatsBase.CoefTable` *This will be moved to another package*
"""
function vif(obj::UnobservedEffectsModel)
	X = get(obj, :X)
	Varlist = get(obj, :Varlist)
	Intercept = get(obj, :Intercept)
	if Intercept
		Varlist = Varlist[2:end]
		X = X[:,2:end]
	end
	Z = Distributions.zscore(X, 1) ./ sqrt(size(X, 1) - 1)
	VIF = diag(inv(cholfact(Z' * Z)))
	VIF = vcat(VIF, mean(VIF))
	Varlist = vcat(Varlist, "Mean VIF")
	@printf "Variance Inflation Factor:\n"
	output = StatsBase.CoefTable([VIF], ["VIF"], Varlist)
end
"""
	fe_or_refe_or_re(fm::DataFrames.Formula,
		df::DataFrames.DataFrame;
		PID::Symbol = names(df)[1],
		TID::Symbol = names(df)[2],
		contrasts = Dict{Symbol, DataFrames.ContrastsMatrix}())

Print the Esarey and Jaffe (2017) Direct Test for Consistency of Random Effects Model.
"""
function fe_or_re(fm::DataFrames.Formula, df::DataFrames.DataFrame; PID::Symbol = names(df)[1], TID::Symbol = names(df)[2], contrasts = Dict{Symbol, DataFrames.ContrastsMatrix}())
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
function fe_or_re(fm::DataFrames.Formula, iv::DataFrames.Formula, df::DataFrames.DataFrame; PID::Symbol = names(df)[1], TID::Symbol = names(df)[2], contrasts = Dict{Symbol, DataFrames.ContrastsMatrix}())
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
