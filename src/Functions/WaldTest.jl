function get_Wald_test(model::UnobservedEffectsModel; VCE::Symbol = :OLS)
	Intercept = get(model, :Intercept)
	β = StatsBase.coef(model)
	V̂ = StatsBase.vcov(model)
	if VCE in [:PID]
		rdf = get(model, :n) - 1
	else
		rdf = StatsBase.dof_residual(model)
	end
	k = length(β) - 1
	if get(model, :Intercept)
		R = hcat(zeros(k), eye(length(β) - 1))
	else
		R = eye(length(β))
	end
	Bread = R * β
	Meat = inv(R * V̂ * R')
	Wald = (Bread' * Meat * Bread) / size(R, 1)
	F_Dist = Distributions.FDist(k, rdf)
	Wald_p = Distributions.ccdf(F_Dist, Wald)
	return Wald, F_Dist, Wald_p
end
