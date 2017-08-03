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
	function getR²VIF(X::Matrix{Float64}, idx::Int64)
		y = X[:,idx]
		X = X[:,setdiff(1:size(X, 2), idx)]
		β = inv(cholfact(X' * X)) * X' * y
		ŷ = X * β
		û = y - ŷ
		RSS = sum(û.^2)
		TSS = sum((y - mean(y)).^2)
		Rsq = 1 - RSS / TSS
		VIF = 1 / ( 1 - Rsq)
	end
	VIF = mapreduce(elem -> getR²VIF(X, elem), vcat, 1:size(X, 2))
	output = hcat(vcat(Varlist, "Mean VIF"), vcat(VIF, mean(VIF)))
end
