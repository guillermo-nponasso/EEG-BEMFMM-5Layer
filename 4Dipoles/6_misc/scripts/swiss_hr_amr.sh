#!/bin/bash

#SBATCH --job-name="SW_HR"
#SBATCH -D .
#SBATCH --output="output_amr/swiss_hr_%a.out"
#SBATCH --error="output_amr/swiss_hr_%a.err"

#SBATCH --array=1-15
#SBATCH --mem=64GB
#SBATCH --cpus-per-task=20
#SBATCH --partition=short
#SBATCH --time=22:00:00
#SBATCH --exclude=compute-3-01

module purge
module load matlab/R2023a

PATNO=$SLURM_ARRAY_TASK_ID

matlab -nodisplay -nosplash -r "wrapper_amr('$PATNO','swiss7_headreco','swiss3')"
