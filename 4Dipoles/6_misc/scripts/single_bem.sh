#!/bin/bash

#SBATCH --job-name="SN_BEM"
#SBATCH -D .
#SBATCH --output="output_bem/SimNIBS_%a.out"
#SBATCH --error="output_bem/SimNIBS_%a.err"

#SBATCH --array=4,5,8,10
#SBATCH --mem=64GB
#SBATCH --cpus-per-task=16
#SBATCH --partition=short
#SBATCH --time=22:00:00
#SBATCH --exclude=compute-3-01

module purge
module load matlab/R2023a

PATNO=$SLURM_ARRAY_TASK_ID

matlab -nodisplay -nosplash -r "create_BEM_model('$PATNO','SimNIBS7','SimNIBS3')"
