### StatisticalModel
## StatsBase.adjr2(obj::StatisticalModel, variant::Symbol)
function StatsBase.adjr2(obj::UnobservedEffectsModel)
	R2 = StatsBase.r²(obj)
	n = StatsBase.nobs(obj)
	p = StatsBase.dof(obj)
	1 - (1 - (1 - R2) * (n - 1) / (n - p))
end
## StatsBase.adjr²(obj::StatisticalModel)
## StatsBase.aic(obj::StatisticalModel) # Default
## StatsBase.aicc(obj::StatisticalModel) # Default
## StatsBase.bic(obj::StatisticalModel) # Default
## StatsBase.coef(obj::StatisticalModel)
function StatsBase.coef(obj::UnobservedEffectsModel)
	get(obj, :β)
end
## StatsBase.deviance(obj::StatisticalModel)
function StatsBase.deviance(obj::UnobservedEffectsModel)
	û = StatsBase.residuals(obj)
	RSS = sum(û.^2)
	RSS / StatsBase.dof_residual(obj)
end
## StatsBase.dof(obj::StatisticalModel)
function StatsBase.dof(obj::UnobservedEffectsModel)
	get(obj, :mdf)
end
## StatsBase.fit(obj::StatisticalModel)
## StatsBase.fit!(obj::StatisticalModel)
## StatsBase.loglikelihood(obj::StatisticalModel)
function StatsBase.loglikelihood(obj::UnobservedEffectsModel)
	sum(
	Distributions.logpdf.(
	Distributions.Normal.(
	StatsBase.fitted(obj),
	sqrt(StatsBase.deviance(obj))),
	StatsBase.model_response(obj)))
end
## StatsBase.nobs(obj::StatisticalModel)
function StatsBase.nobs(obj::UnobservedEffectsModel)
	get(obj, :nobs)
end
## StatsBase.nulldeviance(obj::StatisticalModel)
function StatsBase.nulldeviance(obj::UnobservedEffectsModel)
	y = StatsBase.model_response(obj)
	sum((y - mean(y)).^ 2) / (StatsBase.dof(obj) + StatsBase.dof_residual(obj))
end
## StatsBase.r2(obj::StatisticalModel, variant::Symbol)
function StatsBase.r2(obj::UnobservedEffectsModel)
	get(obj, :R²)
end
## StatsBase.r²(obj::StatisticalModel, variant::Symbol)
### RegressionModel
## StatsBase.dof_residual(obj::RegressionModel)
function StatsBase.dof_residual(obj::UnobservedEffectsModel)
	get(obj, :rdf)
end
## StatsBase.fitted(obj::RegressionModel)
function StatsBase.fitted(obj::UnobservedEffectsModel)
	get(obj, :ŷ)
end
## StatsBase.model_response(obj::RegressionModel)
function StatsBase.model_response(obj::UnobservedEffectsModel)
	get(obj, :y)
end
## StatsBase.predict(obj::RegressionModel, [newX])
function StatsBase.predict(obj::UnobservedEffectsModel, newdata::DataFrames.DataFrame)
	getfield(
	DataFrames.ModelMatrix(
	DataFrames.ModelFrame(
	get(obj, :Formula), newdata)), :m) * StatsBase.coef(obj)
end
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
function StatsBase.vcov(obj::UnobservedEffectsModel; variant::Symbol = :OLS)
	VCE = getVCE(variant)
	estimator = get(obj, :Estimator)
	if isa(estimator, BE)
		@assert isa(VCE, OLS) "The between estimator only allows for `:OLS` variance-covariance estimates."
	elseif isa(estimator, FE)
		@assert (isa(VCE, OLS) | isa(VCE, ClPID) | isa(VCE, ClTID) | isa(VCE, ClPTID)) "The unbiased variance-covariance estimators for fixed effects models are `:OLS` if independence is assumed or a cluster-robust option `PID`, `TID`, `PTID`."
	end
    Bread = get(obj, :Bread)
    X = get(obj, :X)
    ũ = get_ũ(obj, VCE)
    λ = get_λ(obj, VCE)
    Clusters = get_clusters(obj, VCE)
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
							alpha::AbstractFloat = 0.05,
							rdf::Integer = StatsBase.dof_residual(obj))
	@assert in_closed_unit_interval(alpha) "alpha must be ∈ (0,1)"
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
function StatsBase.coeftable(model::UnobservedEffectsModelExogenous; VCE::Symbol = :OLS, α::Float64 = 0.05)
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
    LB, UB = StatsBase.confint(model, VCE = VCE, α = α, rdf = rdf)
    LB = round.(LB, 6)
    UB = round.(UB, 6)
	Effect = get(model, :Effect)
	if Effect == "Panel"
		ModelType = "One-Way (Cross-Sectional) Unobserved Effects Model"
	elseif Effect == "Temporal"
		ModelType = "One-Way (Temporal) Unobserved Effects Model"
	elseif Effect == "TwoWays"
		ModelType = "Two-Ways (Cross-Sectional and Temporal) Unobserved Effects Model"
	end
    @printf "%s\nEstimator: %s\n" ModelType getName(get(model, :Estimator))
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
function StatsBase.coeftable(model::UnobservedEffectsModelEndogenous; VCE::Symbol = :OLS, α::Float64 = 0.05)
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
    LB, UB = StatsBase.confint(model, VCE = VCE, α = α, rdf = rdf)
    LB = round.(LB, 6)
    UB = round.(UB, 6)
	Effect = get(model, :Effect)
	if Effect == "Panel"
		ModelType = "One-Way (Cross-Sectional) Unobserved Effects Model"
	elseif Effect == "Temporal"
		ModelType = "One-Way (Temporal) Unobserved Effects Model"
	elseif Effect == "TwoWays"
		ModelType = "Two-Ways (Cross-Sectional and Temporal) Unobserved Effects Model"
	end
    @printf "%s\nEstimator: %s\n" ModelType getName(get(model, :Estimator))
    @printf "%s + (%s)\n" get(model, :Formula) string(get(model, :iv))[10:end]
    @printf "nobs: %.0f, N: %.0f, n: %.0f, T ∈ [%.0f, %.0f], T̄: %.2f\n" StatsBase.nobs(model) get(model, :N) get(model, :n) T[1] T[3] T[2]
    @printf "Wald Test: F%s = %.2f, Prob > F = %.4f\n" Int.(Distributions.params(F_Dist)) Wald Wald_p
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
