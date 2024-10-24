#!/bin/bash
#SBATCH --job-name="Test1FMM3D"
#SBATCH -D .
#SBATCH --output="test_1.out"
#SBATCH --error="test_1.err"

#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem=16G
#SBATCH --cpus-per-task=16
#SBATCH --partition=short
#SBATCH --time=2:00:00

module purge
module load matlab/R2023a

matlab -nodisplay -nosplash -r test_hfmm3d
