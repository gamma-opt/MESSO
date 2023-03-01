# Run SpineOpt on ETH-Euler HPC
## 1. Connect to the Euler cluster
### - Command line 
In Windows Powershell or Linux/WSL command line:
```
ssh `username`@euler.ethz.ch
```
In my case, that is
```
ssh jiahuang@euler.ethz.ch
```
[Complete instruction](https://scicomp.ethz.ch/wiki/Accessing_the_clusters)
### - File transmission
- Interactive interface: use [WinSCP](https://winscp.net/eng/download.php)
- Command line: [ETH Euler manual](https://scicomp.ethz.ch/wiki/Storage_systems#File_transfer)

## 2. Set up working environment for the very first time
`Git` (need not be loaded) and `Gurobi` (need be loaded) are available in Euler.
- 2.1 Check latest available Julia version by `module spider julia`, then follow the instruction to load the corresponding modules, e.g.
    ```console
    module load gcc/6.3.0 julia/1.7.3 gurobi
    ```
- 2.2 Install relevant julia package in a central `SpineOpt` environment
First of all, move to the working directory and then call `Julia REPL`
    ```console
    cd $HOME/Projects/NordPool-MESSO
    ```
    In Julia REPL
    ```Julia
    julia> ] activate /cluster/home/jiahuang/Tools/SpineOpt
    (SpineOpt) pkg> add SpineInterface#master
    # (SpineOpt) pkg> add https://github.com/Spine-tools/SpineInterface.jl.git#commitSHA
    (SpineOpt) pkg> add SpineOpt#master
    # (SpineOpt) pkg> add https://github.com/Spine-tools/SpineOpt.jl.git#commitSHA
    (SpineOpt) pkg> add JuMP
    (SpineOpt) pkg> add Gurobi
    (SpineOpt) pkg> build Gurobi  # config the gurobi to avoid license inconsistency
    ```
    Or in a `script.jl`
    ```Julia
    import Pkg; Pkg.activate("/cluster/home/jiahuang/Tools/SpineOpt")
    Pkg.add(url="https://github.com/Spine-tools/SpineInterface.jl.git", rev="master")
    Pkg.add(url="https://github.com/Spine-tools/SpineOpt.jl.git", rev="master")
    Pkg.add("JuMP")
    Pkg.add("Gurobi"); Pkg.build("Gurobi")
    ```
    See [`Pkg doc`](https://pkgdocs.julialang.org/v1/managing-packages/) for options to install specific version/branch/commit.
- 2.3 Install `spinedb_api`
Under the directory of the built Julia environment, call Julia REPL and activate the environment
    ```Julia
    julia> ] activate .
    (SpineOpt) pkg> add PyCall
    (SpineOpt) pkg> add Conda
    # Julia 1.7.3 uses Python3.6 which is not supported by spinedb-api, so we need to config a newer python version
    ```
    Then initialise a newer Julia-specific conda python by `using Conda;   Conda.list()`.
    ```Julia
    Using PyCall
    ENV["PYTHON"] = ""
    import Pkg; Pkg.build("PyCall")
    ```
    Relaunch Julia REPL and find the python used by current Julia environment:
    ```Julia
    import Pkg; Pkg.activate("/cluster/home/jiahuang/Tools/SpineOpt")
    using PyCall
    PyCall.pyprogramname
    ```
    Then install `spinedb-api` to the python installed in `PyCall.pyprogramname` by terminal command, e.g.
    ```console
    /cluster/home/jiahuang/.julia/conda/3/bin/python -m pip install --user 'git+https://github.com/Spine-project/Spine-Database-API'
    ```
- 2.4 Maintanence of the packages
    - Update all Julia packages:
    ```Julia
    import Pkg; Pkg.activate("/cluster/home/jiahuang/Tools/SpineOpt"); Pkg.update()
    ```
    - Update `spinedb-dpi`:
    ```console
    /cluster/home/jiahuang/.julia/conda/3/bin/python -m pip install --upgrade --user 'git+https://github.com/Spine-project/Spine-Database-API'
    ```
    - Update other packages installed in the conda python for Julia:
    ```Julia
    import Pkg; Pkg.activate("/cluster/home/jiahuang/Tools/SpineOpt")
    import Conda; Conda.update(); Conda.clean()
    ```
- 2.5 Install `SpineOpt.jl`, `SpineInterface.jl`, and `spinedb-api` from local cloned version
    ```console
    cd $HOME/Tools/SpineOpt
    git clone --branch master https://github.com/Spine-tools/SpineOpt.jl
    git clone --branch master https://github.com/Spine-tools/SpineInterface.jl
    git clone --branch master https://github.com/Spine-project/Spine-Database-API
    julia
    ```
    In Julia REPL
    ```Julia
    julia> ] activate .
    (SpineOpt) pkg> add /cluster/home/jiahuang/Tools/SpineOpt/SpineInterface.jl
    (SpineOpt) pkg> add /cluster/home/jiahuang/Tools/SpineOpt/SpineOpt.jl
    ```
    Install cloned `spinedb-api`
    ```console
    /cluster/home/jiahuang/.julia/conda/3/bin/python -m pip install --user ./Spine-Database-API
    ```
    Other steps remain the same as the above sections 2.1-2.4. Update of packages is documented in `batch_update_SpineOpt_env_local.sh` and `update_env_packages.jl` at directory `$HOME/Tools/SpineOpt`.


## 3. Run the workflow
project directory: `$HOME/Projects/NordPool-MESSO`
environment directory: `$HOME/Tools/SpineOpt`
run batch scripts in a chain:
```console
cd $HOME/Projects/NordPool-MESSO
copy_folder=$(sbatch --parsable -J job1 sbatch_copy_project_folder_to_scratch.sh)
execution=$(sbatch --parsable -J job2 -d afterany:$copy_folder --array=1-8:step sbatch_run_SpineOpt.sh)
sbatch -J job3 -d afterany:$execution sbatch_return_outputdb.sh
```
where `step` is an integer, meaning that the tasks having index = $1+n \cdot step$ within the given range (1-8 in this case) are to be executed ([details](https://scicomp.ethz.ch/wiki/LSF_to_Slurm_quick_reference#Job_array)).

Or simply run the batch script for running SpineOpt
```console
cd $HOME/BatchScripts/NordPool-MESSO
sbatch --array=1-8 sbatch_run_SpineOpt.sh
```
followed by
```console
sbatch_send_back_outputdb.sh
```

## Useful links:
https://scicomp.ethz.ch/wiki/LSF_to_Slurm_quick_reference
https://scicomp.ethz.ch/wiki/Using_the_batch_system#Resource_requirements
https://scicomp.ethz.ch/public/lsla/index2.html
https://scicomp.ethz.ch/wiki/Euler#Summary
