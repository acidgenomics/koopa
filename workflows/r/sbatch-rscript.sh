#!/bin/bash

## Run R script on Harvard O2 cluster.
## Updated 2019-06-21.

## SLURM
## https://slurm.schedmd.com/sbatch.html

#SBATCH --job-name=rscript             # Job name.
#SBATCH --partition=priority           # Partition name.
#SBATCH --time=1-00:00                 # Runtime in 'D-HH:MM' format.
#SBATCH --nodes=1                      # Number of nodes. Keep at 1.
#SBATCH --ntasks=1                     # Number of tasks per node. Keep at 1.
#SBATCH --cpus-per-task=1              # CPU cores requested per task. Change for threaded jobs.
#SBATCH --mem-per-cpu=16G              # Memory needed per CPU.
#SBATCH --error=jobid_%j.err           # File to which 'STDERR' will be written, including job ID.
#SBATCH --output=jobid_%j.out          # File to which 'STDOUT' will be written, including job ID.
#SBATCH --mail-type=ALL                # Type of email notification ('BEGIN', 'END', 'FAIL', 'ALL').

Rscript \
    --default-packages="stats,graphics,grDevices,utils,datasets,methods,base" \
    -e "source('rscript.R')"
