#!/bin/bash

#SBATCH --job-name="SWISS_AMR"
#SBATCH -D .
#SBATCH --output="output_amr/swiss_15.out"
#SBATCH --error="output_amr/swiss_15.err"

#SBATCH --ntasks=1
#SBATCH --mem=64GB
#SBATCH --cpus-per-task=16
#SBATCH --partition=short
#SBATCH --time=22:00:00
#SBATCH --exclude=compute-3-01

module purge
module load matlab/R2023a

matlab -nodisplay -nosplash -r "wrapper_amr('15','swiss7','swiss3')"
