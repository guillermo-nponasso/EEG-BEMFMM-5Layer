#!/bin/bash
#SBATCH --job-name="Test2FMM3D"
#SBATCH -D .
#SBATCH --output="test_2.out"
#SBATCH --error="test_2.err"

#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem=16G
#SBATCH --cpus-per-task=16
#SBATCH --partition=short
#SBATCH --time=2:00:00

module purge
module load matlab/R2023a

matlab -nodisplay -nosplash -r test_lfmm3d
