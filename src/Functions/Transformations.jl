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
    output = mapreduce(panel -> object[panel,:] .- mean(object[panel,:], 1), vcat, Effect) .+ mean(object, 1)
    if Intercept
        output[:,1] = ones(size(output, 1), 1)
    end
    output
end
function transform(estimator::FE, Effect::Vector{Vector{Vector{Int64}}}, object::Matrix{Float64}, Categorical::Vector{Bool}, Intercept::Bool)
    First = mapreduce(panel -> zeros(length(panel)) .- mean(object[panel,:], 1), vcat, Effect[1])
    Second = mapreduce(period -> zeros(length(period)) .- mean(object[period,:], 1), vcat, Effect[2])
    output = object .+ First .+ Second .+ mean(object, 1)
    if Intercept
        output[:,1] = ones(size(output, 1), 1)
    end
    output
end
function transform(estimator::FE, Effect::Vector{Vector{Int64}}, object::Vector{Float64})
    output = mapreduce(panel -> object[panel] - mean(object[panel]), vcat, Effect) + mean(object)
    output = Vector{Float64}(output)
    return output
end
function transform(estimator::FE, Effect::Vector{Vector{Vector{Int64}}}, object::Vector{Float64})
    First = mapreduce(panel -> zeros(length(panel)) .- mean(object[panel]), vcat, Effect[1])
    Second = mapreduce(period -> zeros(length(period)) .- mean(object[period]), vcat, Effect[2])
    output = object + First + Second + mean(object)
    output = Vector{Float64}(output)
    return output
end
function transform(X::AbstractMatrix, X̄::ModelValues_X, θ::ModelValues_θ, Lens::Vector{Int64})
    X̄ = get(X̄)
    θ = get(θ)
	X̄ = mapreduce(times_row -> repmat(last(times_row)', first(times_row), 1), vcat, Iterators.zip(Lens, rows(X̄ .* θ)))
	X - X̄
end
function transform(X::AbstractMatrix, Z::AbstractMatrix, z::AbstractMatrix, θ::ModelValues_θ, Lens::Vector{Int64})
	X̂ = hcat(X, Z)
	θ = get(θ)
	X̄ = mean(X̂, 1) .* θ
	X̂ -= mapreduce(times_row -> repmat(last(times_row)', first(times_row), 1), vcat, Iterators.zip(Lens, rows(X̄)))
	X̂, LinearIndependent = get_fullrank(X̂)
	instruments = X̂ * inv(cholfact(X̂' * X̂)) * X̂'
	ẑ = mapslices(col -> instruments * col, z, 1)
	X̂ = hcat(X, ẑ)
	X̃ = hcat(X, z)
	X̄ = mean(X̃, 1) .* θ
	X̃ -= mapreduce(times_row -> repmat(last(times_row)', first(times_row), 1), vcat, Iterators.zip(Lens, rows(X̄)))
	X̃ = X̃[:,LinearIndependent]
	return (X̂, X̃, LinearIndependent)
end
function transform(y::AbstractVector, ȳ::ModelValues_y, θ::ModelValues_θ, Lens::Vector{Int64})
    ȳ = get(ȳ)
    θ = get(θ)
    ȳ = mapreduce(times_row -> repeat([ last(times_row) ], inner = first(times_row)), vcat, Iterators.zip(Lens, ȳ .* θ))
    ModelValues_y(y - ȳ)
end
function transform(estimator::Estimators, Effect::Vector{Vector{Int64}})
    Effect
end
function transform(estimator::FD, Effect::Vector{Vector{Int64}})
    Lens = length.(Effect) - 1
    getID(mapreduce(idx_length -> repeat([first(idx_length)], inner = last(idx_length)), vcat, enumerate(Lens)))
end
