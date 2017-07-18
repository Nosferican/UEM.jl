function PreModelFrame(fm::DataFrames.Formula, df::DataFrames.DataFrame, PanelID::Symbol, TemporalID::Symbol)
	df = df[:,union([PanelID], [TemporalID], DataFrames.allvars(fm))]
	DataFrames.completecases!(df)
	sort!(df, cols = [PanelID, TemporalID])
	PID = getID(df[PanelID])
	TID = getID(df[TemporalID])
	df, PID, TID
end
function getID(obj::AbstractVector)
	Left = map(level -> findfirst(obj, level), unique(obj))
	Right = vcat(Left[2:end] - 1, length(obj))
	map((left, right) -> left:right, Left, Right)
end
function linear_independent(obj::AbstractMatrix)
	@assert reduce(-, size(obj)) > 0 "Design matrix has more features than observations."
	diag(rref(obj)) .== 1
end
function get_fullrank(obj::AbstractMatrix)
	LinearIndependent = linear_independent(obj)
	output = obj[:,LinearIndependent]
	output, LinearIndependent
end
function hatvalues(obj::Matrix; Bread::Matrix = inv(cholfact(obj)))
	diag(obj * Bread * obj')
end
function in_closed_unit_interval(obj::AbstractVector)
	Min, Max = extrema(obj)
	(Min >= 0) & (Max <= 1)
end
function in_closed_unit_interval(obj::Real)
	(obj >= 0) & (obj <= 1)
end
