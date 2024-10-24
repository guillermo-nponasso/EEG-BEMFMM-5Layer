#!/bin/bash

#SBATCH --job-name="SN_11"
#SBATCH -D .
#SBATCH --output="output_amr/simNIBS_11.out"
#SBATCH --error="output_amr/simNIBS_11.err"

#SBATCH --ntasks=1
#SBATCH --mem=64GB
#SBATCH --cpus-per-task=16
#SBATCH --partition=short
#SBATCH --time=22:00:00
#SBATCH --exclude=compute-3-01

module purge
module load matlab/R2023a

matlab -nodisplay -nosplash -r "wrapper_amr('11','SimNIBS7','SimNIBS3')"
