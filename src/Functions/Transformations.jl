function transform(estimator::PO, Effect::Vector{UnitRange{Int64}}, object::Matrix{Float64}, Categorical::Vector{Bool}, Intercept::Bool)
    object
end
function transform(estimator::PO, Effect::Vector{UnitRange{Int64}}, object::Vector{Float64})
    object
end
function transform(estimator::FD, Effect::Vector{UnitRange{Int64}}, object::Matrix{Float64}, Categorical::Vector{Bool}, Intercept::Bool)
    if Intercept
        Original = union([1], find(Categorical))
    else
        Original = find(Categorical)
    end
    output = reduce(vcat, map(panel -> diff(object[panel,:], 1), Effect))
    output[:,Original] = reduce(vcat, map(panel -> object[panel[2:end],Original], Effect))
    output
end
function transform(estimator::FD, Effect::Vector{UnitRange{Int64}}, object::Vector{Float64})
    output = reduce(vcat, map(panel -> diff(object[panel]), Effect))
    output = Vector{Float64}(output)
    return output
end
function transform(estimator::BE, Effect::Vector{UnitRange{Int64}}, object::Matrix{Float64}, Categorical::Vector{Bool}, Intercept::Bool)
    output = mapreduce(panel -> mean(object[panel,:], 1), vcat, Effect)
    return output
end
function transform(estimator::BE, Effect::Vector{UnitRange{Int64}}, object::Vector{Float64})
    output = mapreduce(panel -> mean(object[panel]), vcat, Effect)
end
function transform(estimator::FE, Effect::Vector{UnitRange{Int64}}, object::Matrix{Float64}, Categorical::Vector{Bool}, Intercept::Bool)
    output = mapreduce(panel -> object[panel,:] .- mean(object[panel,:], 1), vcat, Effect) .+ mean(object, 1)
    if Intercept
        output[:,1] = ones(size(output, 1), 1)
    end
    output
end
function transform(estimator::FE, Effect::Vector{UnitRange{Int64}}, object::Vector{Float64})
    output = mapreduce(panel -> object[panel] - mean(object[panel]), vcat, Effect) + mean(object)
    output = Vector{Float64}(output)
    return output
end
function transform(X::AbstractMatrix, X̄::ModelValues_X, θ::ModelValues_θ, Lens::Vector{Int64})
    X̄ = get(X̄)
    θ = get(θ)
    X̄ = mapreduce(times_row -> repmat(last(times_row)', first(times_row), 1), vcat, Iterators.zip(Lens, rows(X̄ .* θ))) # ArraySlices
    X - X̄
end
function transform(y::AbstractVector, ȳ::ModelValues_y, θ::ModelValues_θ, Lens::Vector{Int64})
    ȳ = get(ȳ)
    θ = get(θ)
    ȳ = mapreduce(times_row -> repeat([ last(times_row) ], inner = first(times_row)), vcat, Iterators.zip(Lens, ȳ .* θ))
    ModelValues_y(y - ȳ)
end
function transform(estimator::Estimators, Effect::Vector{UnitRange{Int64}})
    Effect
end
function transform(estimator::FD, Effect::Vector{UnitRange{Int64}})
    Lens = length.(Effect) - 1
    getID(mapreduce(idx_length -> repeat([first(idx_length)], inner = last(idx_length)), vcat, enumerate(Lens)))
end
