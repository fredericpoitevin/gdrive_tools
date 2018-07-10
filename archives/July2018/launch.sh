#!/bin/bash
#
#SBATCH --job-name=gdup
#SBATCH --output=gdup%j.out
#SBATCH --error=gdup.%j.err
#SBATCH --time=2:00:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --gres gpu:1
#
srun ./upload2gdrive.sh run2
