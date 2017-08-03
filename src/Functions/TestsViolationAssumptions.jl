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
function vif(obj::UnobservedEffectsModel)
	X = get(obj, :X)
	Varlist = get(obj, :Varlist)
	Intercept = get(model, :Intercept)
	if Intercept
		Varlist = Varlist[2:end]
		X = X[:,2:end]
	end
	Z = zscore(X, 1) ./ sqrt(size(X, 1) - 1)
	VIF = diag(inv(cholfact(Z' * Z)))
	VIF = vcat(VIF, mean(VIF))
	Varlist = vcat(Varlist, "Mean VIF")
	@printf "Variance Inflation Factor:\n"
	for idx in eachindex(VIF)
		@printf "%s: %.2f\n" Varlist(idx) VIF(idx)
	end
end
