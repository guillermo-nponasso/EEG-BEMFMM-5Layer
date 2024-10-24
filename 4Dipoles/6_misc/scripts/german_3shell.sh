#!/bin/bash

#SBATCH --job-name="GER_3S"
#SBATCH -D .
#SBATCH --output="output_3shell/german_%a.out"
#SBATCH --error="output_3shell/german_%a.err"

#SBATCH --array=1-15
#SBATCH --mem=64GB
#SBATCH --cpus-per-task=16
#SBATCH --partition=short
#SBATCH --time=22:00:00
#SBATCH --exclude=compute-3-01

module purge
module load matlab/R2023a

PATNO=$SLURM_ARRAY_TASK_ID

matlab -nodisplay -nosplash -r "wrapper_3shell('$PATNO','german3','german3')"
