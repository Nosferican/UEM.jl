abstract type VCE end
struct OLS <: VCE end
struct HC0 <: VCE end
struct HC1 <: VCE end
struct HC2 <: VCE end
struct HC3 <: VCE end
struct HC4 <: VCE end
struct ClPID <: VCE end
struct ClTID <: VCE end
struct ClPTID <: VCE end
function getVCE(obj::Symbol)
	@assert obj in [:OLS, :HC0, :HC1, :HC2, :HC3, :HC4, :PID, :TID, :PTID] "The available variance-covariance estimators are:\n
	Ordinary Least Squares: `:OLS`\n
	HC0 `:HC0`\n
	HC1 `:HC1`\n
	HC2 `:HC2`\n
	HC3: `:HC3`\n
	HC4 `:HC4`\n
	Cluster-Robust by Panel ID: `:PID`\n"
	if obj == :OLS
		output = OLS()
	elseif obj == :HC0
		output = HC0()
	elseif obj == :HC1
		output = HC1()
	elseif obj == :HC2
		output = HC2()
	elseif obj == :HC3
		output = HC3()
	elseif obj == :HC4
		output = HC4()
	elseif obj == :PID
		output = ClPID()
	elseif obj == :TID
		output = ClTID()
	elseif obj == :PTID
		output = ClPTID()
	end
	return output
end
function get_ũ(model::UnobservedEffectsModel, VCE::OLS)
	ones(length(StatsBase.residuals(model)))
end
function get_ũ(model::UnobservedEffectsModel, VCE::HC0)
	StatsBase.residuals(model).^2
end
function get_ũ(model::UnobservedEffectsModel, VCE::HC1)
	StatsBase.residuals(model).^2
end
function get_ũ(model::UnobservedEffectsModel, VCE::HC2)
	X = get(model, :X)
	Bread = get(model, :Bread)
    h = hatvalues(X, Bread = Bread)
    û = StatsBase.residuals(model)
	û.^2 ./ (1 - h)
end
function get_ũ(model::UnobservedEffectsModel, VCE::HC3)
	X = get(model, :X)
	Bread = get(model, :Bread)
    h = hatvalues(X, Bread = Bread)
    û = StatsBase.residuals(model)
	(û ./ (1 - h)).^2
end
function get_ũ(model::UnobservedEffectsModel, VCE::HC4)
	X = get(model, :X)
	Bread = get(model, :Bread)
	h = hatvalues(X, Bread = Bread)
	N, k = size(X)
	û = StatsBase.residuals(model)
	û.^2 ./ (1 - h).^min.(4, N / k * h)
end
function get_ũ(model::UnobservedEffectsModel, VCE::ClPID)
	StatsBase.residuals(model)
end
function get_ũ(model::UnobservedEffectsModel, VCE::ClTID)
	StatsBase.residuals(model)
end
function get_ũ(model::UnobservedEffectsModel, VCE::ClPTID)
	StatsBase.residuals(model)
end
function get_λ(model::UnobservedEffectsModel, VCE::VCE)
	one(Float64)
end
function get_λ(model::UnobservedEffectsModel, VCE::OLS)
	get(model, :MRSS)
end
function get_λ(model::UnobservedEffectsModel, VCE::HC1)
	N, k = size(get(model, :X))
	N / (N - k)
end
function get_λ(model::UnobservedEffectsModel, VCE::ClPID)
	N, k = size(get(model, :X))
	n = get(model, :n)
	n / (n - 1) * (N - 1) / (N - k)
end
function get_λ(model::UnobservedEffectsModel, VCE::ClTID)
	N, k = size(get(model, :X))
	n = length(get(model, :TID))
	n / (n - 1) * (N - 1) / (N - k)
end
function get_λ(model::UnobservedEffectsModel, VCE::ClPTID)
	N, k = size(get(model, :X))
	n = min(get(model, :n), length(get(model, :TID)))
	n / (n - 1) * (N - 1) / (N - k)
end
function get_clusters(model::UnobservedEffectsModel, VCE::VCE)
	map(idx -> [idx], eachindex(StatsBase.residuals(model)))
end
function get_clusters(model::UnobservedEffectsModel, VCE::ClPID)
	get(model, :PID)
end
function make_meat(X::Matrix{Float64}, ũ::Vector{Float64}, Clusters::Vector{Vector{Int64}})
	if (length(Clusters) == length(ũ))
		Meat = X' * diagm(ũ) * X
	else
		Meat = zeros(size(X, 2), size(X, 2))
		for idx in eachindex(Clusters)
			Meat += X[Clusters[idx],:]' * ũ[Clusters[idx]] * ũ[Clusters[idx]]' * X[Clusters[idx],:]
		end
	end
	Meat
end
function make_meat(X::Matrix{Float64}, ũ::Vector{Float64}, Clusters::Vector{Vector{Vector{Int64}})
	First = zeros(size(X, 2), size(X, 2))
	for idx in eachindex(Clusters[1])
		First += X[Clusters[1][idx],:]' * ũ[Clusters[1][idx]] * ũ[Clusters[1][idx]]' * X[Clusters[1][idx],:]
	end
	Second = zeros(size(X, 2), size(X, 2))
	for idx in eachindex(Clusters[2])
		Second += X[Clusters[2][idx],:]' * ũ[Clusters[2][idx]] * ũ[Clusters[2][idx]]' * X[Clusters[2][idx],:]
	end
	Intersection = filter(elem -> length(elem) > 0, [ collect(intersect(panel, time)) for panel in Clusters[1] for time in Clusters[2] ])
	Third = zeros(size(X, 2), size(X, 2))
	for idx in eachindex(Intersection)
		Third += X[Intersection[idx],:]' * ũ[Intersection[idx]] * ũ[Intersection[idx]]' * X[Intersection[idx],:]
	end
	First + Second - Third
end
