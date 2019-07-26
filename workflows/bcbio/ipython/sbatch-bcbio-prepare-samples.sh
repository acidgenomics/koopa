#!/bin/sh

## Prepare bcbio samples.
## Harvard O2 cluster.
## Updated 2019-06-21.

## SLURM
## https://slurm.schedmd.com/sbatch.html

#SBATCH --job-name=bcbio               # Job name.
#SBATCH --partition=medium             # Partition (queue).
#SBATCH --time=1-00:00                 # Runtime in D-HH:MM format.
#SBATCH --nodes=1                      # Number of nodes (keep at 1).
#SBATCH --ntasks=1                     # Number of tasks per node (keep at 1).
#SBATCH --cpus-per-task=1              # CPU cores requested per task (change for threaded jobs).
#SBATCH --mem-per-cpu=8G               # Memory needed per CPU.
#SBATCH --output=jobid_%j.out          # File to which STDOUT will be written, including job ID.
#SBATCH --error=jobid_%j.err           # File to which STDERR will be written, including job ID.
#SBATCH --mail-type=ALL                # Type of email notification (BEGIN, END, FAIL, ALL).

## This script requires sratoolkit (fastq-dump).
## Match the number of cores to the number of samples.

bcbio_prepare_samples.py \
    --csv "samples.csv" \
    --out fastq \
    -n 12 \
    -t ipython \
    -s slurm \
    -q medium \
    -r t=1-00:00 \
    --retries 3 \
    --timeout 1000
