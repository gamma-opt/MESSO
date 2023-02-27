#!/bin/bash
#SBATCH -n 1
#SBATCH --time=05:00 # 5 minitues run-time
#SBATCH --mem-per-cpu=4G
#SBATCH --job-name=install_SpineOpt_env
#SBATCH --mail-type=BEGIN,END,FAIL # send an email when the job begins, ends, and fails
#SBATCH --error=errors.log # append job’s error messages to errors.log

# to execute this script: "sbatch batch_run-test.sh"

cd $HOME
# Update before copy
## Get internet access
module load gurobi gcc/6.3.0 julia/1.7.3

rm -rf $SCRATCH/NordPool-MESSO   # remove the directory before copying
cp -r $HOME/Projects/NordPool-MESSO $SCRATCH/NordPool-MESSO
cd $SCRATCH/NordPool-MESSO

julia scripts/test.jl

cp $SCRATCH/NordPool-MESSO/outputDB/outputDB.sqlite $HOME/Projects/NordPool-MESSO/outputDB/outputDB.sqlite