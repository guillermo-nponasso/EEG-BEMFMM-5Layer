#!/bin/bash

#SBATCH --job-name="GE_BEM"
#SBATCH -D .
#SBATCH --output="output_bem/german_%a.out"
#SBATCH --error="output_bem/german_%a.err"

#SBATCH --array=1-15
#SBATCH --mem=64GB
#SBATCH --cpus-per-task=16
#SBATCH --partition=short
#SBATCH --time=22:00:00
#SBATCH --exclude=compute-3-01

module purge
module load matlab/R2023a

PATNO=$SLURM_ARRAY_TASK_ID

matlab -nodisplay -nosplash -r "create_BEM_model('$PATNO','german7','german3')"
