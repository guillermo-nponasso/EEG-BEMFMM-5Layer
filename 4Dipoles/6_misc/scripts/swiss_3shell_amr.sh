#!/bin/bash

#SBATCH --job-name="SWISS3_AMR"
#SBATCH -D .
#SBATCH --output="output_3shell/swiss_amr_%a.out"
#SBATCH --error="output_3shell/swiss_amr_%a.err"

#SBATCH --array=1-15
#SBATCH --mem=64GB
#SBATCH --cpus-per-task=16
#SBATCH --partition=short
#SBATCH --time=22:00:00
#SBATCH --exclude=compute-3-01

module purge
module load matlab/R2023a

PATNO=$SLURM_ARRAY_TASK_ID

matlab -nodisplay -nosplash -r "wrapper_3shell_amr('$PATNO','swiss3','swiss3')"
