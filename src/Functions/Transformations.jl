function transform(estimator::PO, Effect::Vector{Vector{Int64}}, object::Matrix{Float64}, Categorical::Vector{Bool}, Intercept::Bool)
    object
end
function transform(estimator::PO, Effect::Vector{Vector{Int64}}, object::Vector{Float64})
    object
end
function transform(estimator::FD, Effect::Vector{Vector{Int64}}, object::Matrix{Float64}, Categorical::Vector{Bool}, Intercept::Bool)
    if Intercept
        Original = union([1], find(Categorical))
    else
        Original = find(Categorical)
    end
    output = reduce(vcat, map(panel -> diff(object[panel,:], 1), Effect))
    output[:,Original] = reduce(vcat, map(panel -> object[panel[2:end],Original], Effect))
    output
end
function transform(estimator::FD, Effect::Vector{Vector{Int64}}, object::Vector{Float64})
    output = reduce(vcat, map(panel -> diff(object[panel]), Effect))
    output = Vector{Float64}(output)
    return output
end
function transform(estimator::BE, Effect::Vector{Vector{Int64}}, object::Matrix{Float64}, Categorical::Vector{Bool}, Intercept::Bool)
    output = mapreduce(panel -> mean(object[panel,:], 1), vcat, Effect)
    return output
end
function transform(estimator::BE, Effect::Vector{Vector{Int64}}, object::Vector{Float64})
    output = mapreduce(panel -> mean(object[panel]), vcat, Effect)
end
function transform(estimator::FE, Effect::Vector{Vector{Int64}}, object::Matrix{Float64}, Categorical::Vector{Bool}, Intercept::Bool)
    output = mapreduce(panel -> object[panel,:] .- mean(object[panel,:], 1), vcat, Effect)
end
function transform(estimator::FE, Effect::Vector{Vector{Vector{Int64}}}, object::Matrix{Float64}, Categorical::Vector{Bool}, Intercept::Bool)
    PID = Effect[1]
    TID = Effect[2]
    PID_means = map(group -> mean(object[group,:], 1), PID)
    TID_means = map(group -> mean(object[group,:], 1), TID)
    means = mean(object, 1)
    argPID = zeros(size(object,1), size(object, 2))
    for group in 1:length(PID_means)
        argPID[PID[group],:] = repmat(PID_means[group], length(PID[group]), 1)
    end
    argTID = zeros(size(object,1), size(object, 2))
    for group in 1:length(TID_means)
        argTID[TID[group],:] = repmat(TID_means[group], length(TID[group]), 1)
    end
    output = object - argPID - argTID .+ means
    if Intercept
        output[:,1] = ones(size(output, 1), 1)
    end
    output
end
function transform(estimator::FE, Effect::Vector{Vector{Int64}}, object::Vector{Float64})
    output = mapreduce(panel -> object[panel] - mean(object[panel]), vcat, Effect)
    output = Vector{Float64}(output)
end
function transform(estimator::FE, Effect::Vector{Vector{Vector{Int64}}}, object::Vector{Float64})
    PID = Effect[1]
    TID = Effect[2]
    PID_means = map(group -> mean(object[group], 1), PID)
    TID_means = map(group -> mean(object[group], 1), TID)
    argPID = zeros(length(object))
    for group in 1:length(PID_means)
        argPID[PID[group]] = repeat(PID_means[group], inner = length(PID[group]))
    end
    argTID = zeros(length(object))
    for group in 1:length(TID_means)
        argTID[TID[group]] = repeat(TID_means[group], inner = length(TID[group]))
    end
    output = Vector{Float64}(object - argPID - argTID + mean(object))
    return output
end
function transform(X::AbstractMatrix, X̄::ModelValues_X, θ::ModelValues_θ, Lens::Vector{Int64})
    X̄ = get(X̄)
    θ = get(θ)
    X̄ .*= θ
	X̄ = mapreduce(times_row -> repmat(last(times_row)', first(times_row), 1), vcat, Iterators.zip(Lens, map(idx -> X̄[idx,:], 1:size(X̄, 1))))
	X - X̄
end
function transformID(estimator::Estimators, Effect::Vector{Vector{Int64}})
	Effect
end
function transformID(estimator::FD, Effect::Vector{Vector{Int64}})
	Lens = length.(Effect) - 1
	getID(mapreduce(idx_length -> repeat([first(idx_length)], inner = last(idx_length)), vcat, enumerate(Lens)))
end
