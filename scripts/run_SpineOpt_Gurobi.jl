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
println("*** Unlisted active values: ***")
for key in setdiff(keys(m.ext[:spineopt].values), keys(m.ext[:spineopt].outputs))
    !isempty(m.ext[:spineopt].values[key]) && println(key)
end

"""
A function to print the active items in the built SpineOpt model.
"""
function print_active(m::JuMP.Model, item::Symbol)
    println("*** Active $item: ***")
    eval(
        :(for key in keys(m.ext[:spineopt].$item)
            !(isempty(m.ext[:spineopt].$item[key]) || isequal(m.ext[:spineopt].$item[key], (0, 0))) && println(key)
        end)
    )
end

items = [:variables, :constraints, :objective_terms]
for i in items
    print_active(m, i)
end