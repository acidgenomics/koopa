#!/bin/bash

# bcbio_setup_genome.py
# Harvard Medical School O2 Cluster

# SLURM
# https://slurm.schedmd.com/sbatch.html

# Use `highmem` partition instead if there are memory issues with hisat2.
# `medium` partition has a memory limit of 250 GB.

#SBATCH --job-name=genome              # Job name
#SBATCH --partition=medium             # Partition name
#SBATCH --time=3-00:00                 # Runtime in D-HH:MM format
#SBATCH --nodes=1                      # Number of nodes (keep at 1)
#SBATCH --ntasks=1                     # Number of tasks per node (keep at 1)
#SBATCH --cpus-per-task=8              # CPU cores requested per task (change for threaded jobs)
#SBATCH --mem=250G                     # Memory needed per node
#SBATCH --error=jobid_%j.err           # File to which STDERR will be written, including job ID
#SBATCH --output=jobid_%j.out          # File to which STDOUT will be written, including job ID
#SBATCH --mail-type=ALL                # Type of email notification (BEGIN, END, FAIL, ALL)

# shellcheck source=/dev/null
. "${GENOME}.sh"
