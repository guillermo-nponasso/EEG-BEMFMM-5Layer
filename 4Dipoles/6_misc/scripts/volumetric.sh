#!/bin/bash

#SBATCH --job-name="VOLUMETRIC_PAT1"
#SBATCH -D .
#SBATCH --output="vol_output/dipole_%a.out"
#SBATCH --error="vol_output/dipole_%a.err"

#SBATCH --array=2
#SBATCH --mem=1024GB
#SBATCH --cpus-per-task=24
#SBATCH --exclude=compute-3-[01-07]
#SBATCH --partition=short
#SBATCH --time=22:00:00

module purge
module load matlab/R2023a

matlab -nodisplay -nosplash -r "volumetric_pat1('$SLURM_ARRAY_TASK_ID')"
