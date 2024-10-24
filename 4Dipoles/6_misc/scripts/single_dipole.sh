#!/bin/bash

#SBATCH --job-name="GER_D1"
#SBATCH -D .
#SBATCH --output="output_amr/german_dip1_1.out"
#SBATCH --error="output_amr/german_dip1_1.err"

#SBATCH --ntasks=1
#SBATCH --mem=64GB
#SBATCH --cpus-per-task=16
#SBATCH --partition=short
#SBATCH --time=22:00:00
#SBATCH --exclude=compute-3-01

module purge
module load matlab/R2023a

matlab -nodisplay -nosplash -r "wrapper_single_dipole('1','german7','german3', 'dip1.txt')"
