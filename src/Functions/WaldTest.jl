function get_Wald_test(model::UnobservedEffectsModel; VCE::Symbol = :OLS)
	Intercept = get(model, :Intercept)
	β = StatsBase.coef(model)
	V̂ = StatsBase.vcov(model, variant = VCE)
	if VCE == :PID
		rdf = length(get(model, :PID)) - 1
	elseif VCE == :TID
		rdf = length(get(model, :TID)) - 1
	elseif VCE == :PTID
		rdf = min(length(get(model, :PID)), length(get(model, :TID))) - 1
	else
		rdf = StatsBase.dof_residual(model)
	end
	k = StatsBase.dof(model)
	if Intercept
		R = hcat(zeros(k), eye(k))
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
