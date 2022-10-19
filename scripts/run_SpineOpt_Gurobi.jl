#=
run_spineopt_Gurobi:
- Author: Huang, Jiangyi
- Date: 2022-10-16
=#

using SpineOpt
using Gurobi
using JuMP

@time begin
    m = run_spineopt(
			ARGS...,
			mip_solver=optimizer_with_attributes(Gurobi.Optimizer),
			lp_solver=optimizer_with_attributes(Gurobi.Optimizer)
		)
end

# Show active variables and constraints
println("*** Active variables: ***")
for key in keys(m.ext[:spineopt].variables)
    !isempty(m.ext[:spineopt].variables[key]) && println(key)
end
println("*** Active constraints: ***")
for key in keys(m.ext[:spineopt].constraints)
    !isempty(m.ext[:spineopt].constraints[key]) && println(key)
end
println("*** Unlisted active values: ***")
for key in setdiff(keys(m.ext[:spineopt].values), keys(m.ext[:spineopt].outputs))
    !isempty(m.ext[:spineopt].values[key]) && println(key)
end