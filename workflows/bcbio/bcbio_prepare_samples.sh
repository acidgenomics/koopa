#!/bin/bash

# https://slurm.schedmd.com/sbatch.html

#SBATCH --job-name=GSE65267         # Job name
#SBATCH --partition=medium          # Partition (queue)
#SBATCH --time=1-00:00              # Runtime in D-HH:MM format
#SBATCH --nodes=1                   # Number of nodes (keep at 1, except when using MPI queue)
#SBATCH --ntasks=1                  # Number of cores per node (keep at 1)
#SBATCH --cpus-per-task=1           # CPUs per task
#SBATCH --mem-per-cpu=8G            # Memory needed per CPU
#SBATCH --output=jobid_%j.out       # File to which STDOUT will be written, including job ID
#SBATCH --error=jobid_%j.err        # File to which STDERR will be written, including job ID
#SBATCH --mail-type=ALL             # Type of email notification (BEGIN, END, FAIL, ALL)

# This script requires sratoolkit (fastq-dump)
# Match the number of cores to the number of samples

csv="samples.csv"
nsamples=12

bcbio_prepare_samples.py --csv "$csv" --out fastq -n "$nsamples" -t ipython -s slurm -q medium -r t=1-00:00 --retries 3 --timeout 1000
