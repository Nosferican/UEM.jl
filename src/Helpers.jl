function PreModelFrame(fm::DataFrames.Formula, df::DataFrames.DataFrame, PanelID::Symbol, TemporalID::Symbol)
	df = df[:,union([PanelID], [TemporalID], DataFrames.allvars(fm))]
	DataFrames.completecases!(df)
	sort!(df, cols = [PanelID, TemporalID])
	PID = getID(Vector(df[PanelID]))
	TID = getID(Vector(df[TemporalID]))
	df, PID, TID
end
function PreModelFrame(fm::DataFrames.Formula, iv::DataFrames.Formula, df::DataFrames.DataFrame, PanelID::Symbol, TemporalID::Symbol)
	df = df[:,union([PanelID], [TemporalID], DataFrames.allvars(fm), DataFrames.allvars(iv))]
	DataFrames.completecases!(df)
	sort!(df, cols = [PanelID, TemporalID])
	PID = getID(Vector(df[PanelID]))
	TID = getID(Vector(df[TemporalID]))
	df, PID, TID
end
function getID(obj::AbstractVector)
	map(idx -> find(obj .== idx), unique(obj))
end
function linear_independent(obj::AbstractMatrix)
	@assert reduce(-, size(obj)) > 0 "Design matrix has more features than observations."
	tmp = rref(round.(obj, 12))
	mapslices(col -> col[max(1, findfirst(col))] .== 1., tmp, 1)[1,:]
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
function get_stars(p_value)
    if p_value > 0.1
        sig = "   "
    elseif p_value > 0.05
        sig = "*  "
    elseif p_value > 0.01
        sig = "** "
    else
        sig = "***"
    end
    return sig
end
