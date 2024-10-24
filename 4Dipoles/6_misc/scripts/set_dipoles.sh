#!/bin/bash

#SBATCH --job-name="SET_DIPO"
#SBATCH -D .
#SBATCH --output="output_dipoles/set_dipoles_%a.out"
#SBATCH --error="output_dipoles/set_dipoles_%a.err"

#SBATCH --array=1-15
#SBATCH --mem=64GB
#SBATCH --cpus-per-task=16
#SBATCH --partition=short
#SBATCH --time=22:00:00
#SBATCH --exclude=compute-3-01

module purge
module load matlab/R2023a

PATNO=$SLURM_ARRAY_TASK_ID

matlab -nodisplay -nosplash -r "set_dipoles('$PATNO')"
