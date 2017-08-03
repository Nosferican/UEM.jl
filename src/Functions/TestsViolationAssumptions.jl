function hettest(obj::UnobservedEffectsModel)
	y = StatsBase.residuals(obj).^2
	X = hcat(ones(length(y)), StatsBase.fitted(obj))
	Bread = inv(cholfact(X' * X))
	β = Bread * X' * y
	ŷ = X * β
	û = y - ŷ
	MESS = sum((ŷ - mean(y)) .^ 2)
	RSS = û.^2
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
