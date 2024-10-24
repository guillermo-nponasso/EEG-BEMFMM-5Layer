#!/bin/bash

#SBATCH --job-name=FT_SWISS
#SBATCH -D .
#SBATCH --output=ftoutput/ftswiss_%a.out
#SBATCH --error=ftoutput/ftswiss_%a.err

#SBATCH --array=1-15
#SBATCH --mem=32G
#SBATCH --cpus-per-task=12
#SBATCH --time=12:00:00
#SBATCH --partition=short
#SBATCH --exclude=compute-3-01

module purge
module load matlab/R2023a

matlab -nodisplay -nosplash -r "create_ft_model('$SLURM_ARRAY_TASK_ID', 'swiss3')"

