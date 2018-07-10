#!/bin/bash
#
#SBATCH --job-name=ctrl_gdup
#SBATCH --output=ctrl_gdup%j.out
#SBATCH --error=ctrl_gdup.%j.err
#SBATCH --mail-type=FAIL
#SBATCH --begin=now+2hour
#SBATCH --dependency=singleton
#SBATCH --time=00:02:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --gres gpu:1
#
nlines=$( squeue -n gdup | wc -l )
if [ $nlines -eq 2 ]; then 
scancel -n gdup
fi
sbatch launch.sh
sbatch $0
