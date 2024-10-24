#!/bin/bash

#SBATCH --job-name="SN_SINGLE"
#SBATCH -D .
#SBATCH --output="output_amr/SimNIBS_%a.out"
#SBATCH --error="output_amr/SimNIBS_%a.err"

#SBATCH --exclude=compute-3-01
#SBATCH --array=1,3,4,[6-8]
#SBATCH --mem=64GB
#SBATCH --cpus-per-task=20
#SBATCH --partition=short
#SBATCH --time=22:00:00
#SBATCH --exclude=compute-3-01

module purge
module load matlab/R2023a

matlab -nodisplay -nosplash -r "wrapper_amr('$SLURM_ARRAY_TASK_ID','SimNIBS7','SimNIBS3')"
