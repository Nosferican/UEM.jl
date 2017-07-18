abstract type Estimators end
struct PO <: Estimators end
struct FD <: Estimators end
struct BE <: Estimators end
struct FE <: Estimators end
struct RE <: Estimators end
function getEstimator(obj::Symbol)
	@assert obj in [:PO, :FD, :BE, :FE, :RE] "The available estimators are:\n
	Pooling Ordinary Least Squares: `:PO`\n
	First-Difference Estimator: `:FD`\n
	Between Estimator: `:BE`\n
	Fixed Effects Model (Within Estimator): `:FE`\n
	Random Effects (Swamy Arora Harmonic Mean Estimator): `:RE`\n"
	if obj == :PO
		output = PO()
	elseif obj == :FD
		output = FD()
	elseif obj == :BE
		output = BE()
	elseif obj == :FE
		output = FE()
	elseif obj == :RE
		output = RE()
	end
	return output
end
function getName(obj::PO)
	"Pooling Ordinary Least Squares Estimator"
end
function getName(obj::FD)
	"First-Difference Estimator"
end
function getName(obj::BE)
	"Between Estimator"
end
function getName(obj::FE)
	"Fixed Effects Estimator"
end
function getName(obj::RE)
	"Random Effects Model (Swamy Arora - Harmonic Mean)"
end
