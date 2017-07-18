function get_Wald_test(model::UnobservedEffectsModel; VCE::Symbol = :OLS)
    β = StatsBase.coef(model)
    V̂ = StatsBase.vcov(model)
    if VCE in [:PID]
        rdf = get(model, :n) - 1
    else
        rdf = StatsBase.dof_residual(model)
    end
    if get(model, :Intercept)
        R = hcat(zeros((length(β) - 1)), eye(length(β) - 1))
    else
        R = eye(length(β))
    end
    Bread = R * β
    Meat = inv(R * V̂ * R')
    Wald = (Bread' * Meat * Bread) / size(R, 1)
    mdf = StatsBase.dof(model)
    F_Dist = Distributions.FDist(mdf, rdf)
    Wald_p = Distributions.ccdf(F_Dist, Wald)
    return Wald, F_Dist, Wald_p
end
