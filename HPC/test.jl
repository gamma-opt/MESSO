#=
run_spineopt_script:
- Author: Huang, Jiangyi
- Date: 2023-Jan-06
=#

# Activate the Julia working environment 
import Pkg
Pkg.activate(".")
# Initial installation of needed packages
Pkg.add(url="https://github.com/Spine-project/SpineInterface.jl.git", rev="master")
Pkg.add(url="https://github.com/Spine-project/SpineOpt.jl.git", rev="master")
Pkg.add("JuMP")
Pkg.add("Gurobi")

# Update the installed packages if needed
Pkg.update()

using SpineOpt
using JuMP
using Gurobi 

input_db_url = "sqlite:///./inputDB/inputDB.sqlite"
output_db_url = "sqlite:///./outputDB/outputDB.sqlite"

@time begin
    m = run_spineopt(
            input_db_url, output_db_url,
			mip_solver=optimizer_with_attributes(Gurobi.Optimizer),
			lp_solver=optimizer_with_attributes(Gurobi.Optimizer),
            filters=Dict("tool" => "object_activity_control", "scenario" => ["WithSourceFuelCost_EffUp_MILP"]),
            alternative="WithSourceFuelCost_EffUp_MILP"
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