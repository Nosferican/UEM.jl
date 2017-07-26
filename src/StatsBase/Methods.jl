### StatisticalModel
## StatsBase.adjr2(obj::StatisticalModel, variant::Symbol)
## StatsBase.adjr²(obj::StatisticalModel, variant::Symbol)
## StatsBase.aic(obj::StatisticalModel)
## StatsBase.aicc(obj::StatisticalModel)
## StatsBase.bic(obj::StatisticalModel)
## StatsBase.coef(obj::StatisticalModel)
function StatsBase.coef(obj::UnobservedEffectsModel)
	get(obj, :β)
end
## StatsBase.deviance(obj::StatisticalModel)
## StatsBase.dof(obj::StatisticalModel)
function StatsBase.dof(obj::UnobservedEffectsModel)
	get(obj, :mdf)
end
## StatsBase.fit(obj::StatisticalModel)
## StatsBase.fit!(obj::StatisticalModel)
## StatsBase.loglikelihood(obj::StatisticalModel)
## StatsBase.nobs(obj::StatisticalModel)
function StatsBase.nobs(obj::UnobservedEffectsModel)
	get(obj, :nobs)
end
## StatsBase.nulldeviance(obj::StatisticalModel)
## StatsBase.r2(obj::StatisticalModel, variant::Symbol)
# function StatsBase.r2(obj::UnobservedEffectsModel)
# 	Core.getfield(obj, :R²)
# end
## StatsBase.r²(obj::StatisticalModel, variant::Symbol)
function StatsBase.r²(obj::UnobservedEffectsModel)
	get(obj, :R²)
end
### RegressionModel
## StatsBase.dof_residual(obj::RegressionModel)
function StatsBase.dof_residual(obj::UnobservedEffectsModel)
	get(obj, :rdf)
end
## StatsBase.fitted(obj::RegressionModel)
function StatsBase.fitted(obj::UnobservedEffectsModel)
	get(model, :ŷ)
end
## StatsBase.model_response(obj::RegressionModel)
function StatsBase.model_response(obj::UnobservedEffectsModel)
	get(obj, :y)
end
## StatsBase.predict(obj::RegressionModel, [newX])
## StatsBase.predict!(obj::RegressionModel, [newX])
## StatsBase.residuals(obj::RegressionModel)
function StatsBase.residuals(obj::UnobservedEffectsModel)
	get(obj, :û)
end
## StatsBase.vcov(obj::StatisticalModel, variant::Symbol)
"""
This function returns the Variance-covariance matrix of an Unobserved Effects Model.

	obj::UnobservedEffectsModel
	variant::Symbol = :OLS
"""
function StatsBase.vcov(model::UnobservedEffectsModel; variant::Symbol = :OLS)
	VCE = getVCE(variant)
	estimator = get(model, :Estimator)
	if isa(estimator, BE)
		@assert isa(VCE, OLS) "The between estimator only allows for `:OLS` variance-covariance estimates."
	elseif isa(estimator, FE)
		@assert (isa(VCE, OLS) | isa(VCE, ClPID)) "The unbiased variance-covariance estimators for fixed effects models are `:OLS` if independence is assumed or `PID`."
	end
    Bread = get(model, :Bread)
    X = get(model, :X)
    ũ = get_ũ(model, VCE)
    λ = get_λ(model, VCE)
    Clusters = get_clusters(model, VCE)
	Meat = make_meat(X, ũ, Clusters)
	λ * Bread * Meat * Bread
end
## StatsBase.stderr(obj::StatisticalModel, variant::Symbol)
"""
This function returns the standard errors for the coefficients of an Unobserved Effects Model.

	obj::UnobservedEffectsModel
	variant::Symbol = :OLS
"""
function StatsBase.stderr(obj::UnobservedEffectsModel; variant::Symbol = :OLS)
	sqrt.(diag(StatsBase.vcov(obj, variant = variant)))
end
## StatsBase.confint(obj::StatisticalModel)
function StatsBase.confint(obj::UnobservedEffectsModel;
							VCE::Symbol = :OLS,
							α::Real = 0.05,
							rdf::Integer = StatsBase.dof_residual(obj))
	@assert in_closed_unit_interval(α) "α must be ∈ (0,1)"
	T_Dist = Distributions.TDist(rdf)
	tstar = Base.quantile(T_Dist, 1 - α / 2)
	β = StatsBase.coef(obj)
	se = StatsBase.stderr(obj, variant = VCE)
	movement = tstar * se
	LB = β - movement
	UB = β + movement
	return (LB, UB)
end
## StatsBase.coeftable(obj::StatisticalModel)
function StatsBase.coeftable(model::UnobservedEffectsModel; VCE::Symbol = :OLS, α::Float64 = 0.05)
    if VCE in [:PID]
        rdf = get(model, :n) - 1
    else
        rdf = StatsBase.dof_residual(model)
    end
    Wald, F_Dist, Wald_p = get_Wald_test(model, VCE = VCE)
    T = get(model, :T)
    β = StatsBase.coef(model)
    se = StatsBase.stderr(model, variant = VCE)
    t = round.(β ./ se, 2)
    β = round.(β, 6)
    se = round.(se, 6)
    T_dist = Distributions.TDist(rdf)
    p_values = 2 * Distributions.ccdf(T_dist, abs.(t))
    LB, UB = StatsBase.confint(model, rdf = rdf)
    LB = round.(LB, 6)
    UB = round.(UB, 6)
    @printf "One-Way (Cross-Sectional) Unobserved Effects Model\nEstimator: %s\n" getName(get(model, :Estimator))
    @printf "%s\n" get(model, :Formula)
    @printf "nobs: %.0f, N: %.0f, n: %.0f, T ∈ [%.0f, %.0f], T̄: %.2f\n" StatsBase.nobs(model) get(model, :N) get(model, :n) T[1] T[3] T[2]
    @printf "Wald Test: F%s = %.2f, Prob > F = %.4f\n" Int.(Distributions.params(F_Dist)) Wald Wald_p
    @printf "R²: %.4f\n" StatsBase.r2(model)
    @printf "Variance-covariance estimator: %s\n" string(VCE)
    @printf "%.2f Confidence Intervals\n" (1 - α)
    fe12 = Formatting.FormatExpr("{:>12}")
    fe4 = Formatting.FormatExpr("{:>4}")
    fe6 = Formatting.FormatExpr("{:>6}")
    widths = [fe12, fe12, fe4, fe6, fe12, fe12]
    cols = [ [β]; ; [se]; [t]; [p_values]; [LB]; [UB] ]
    cols = map(idx -> Formatting.format.(widths[idx], cols[idx]), eachindex(cols))
	Mat = hcat(β, se, t, p_values, LB, UB)
    colnms = ["β   ", "Std. Error", "t  ", "P > |t|", "Lower Bound", "Upper Bound"]
    rownms = get(model, :Varlist)
    output = StatsBase.CoefTable(Mat, colnms, rownms, 4)
end
