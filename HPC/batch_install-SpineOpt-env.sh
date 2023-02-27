#!/bin/bash
#SBATCH -n 4
#SBATCH --time=10:00 # 10 minitues run-time
#SBATCH --mem-per-cpu=4G
#SBATCH --job-name=install_SpineOpt_env
#SBATCH --mail-type=BEGIN,END,FAIL # send an email when the job begins, ends, and fails
#SBATCH --error=errors.log # append job’s error messages to errors.log

# Setup SpineOpt environment for the first time
# To execute this script: "sbatch batch_install-SpineOpt-env.sh"

# load packages
module load gurobi gcc/6.3.0 julia/1.7.3

cd $HOME/Projects/NordPool-MESSO
# Update before copy
## Get internet access


rm -rf $SCRATCH/NordPool-MESSO   # remove the directory before copying
cp -r Projects/NordPool-MESSO $SCRATCH/NordPool-MESSO
cd $SCRATCH/NordPool-MESSO

julia scripts/test.jl

cp $SCRATCH/NordPool-MESSO/outputDB/outputDB.sqlite $HOME/Projects/NordPool-MESSO/outputDB/outputDB.sqlite