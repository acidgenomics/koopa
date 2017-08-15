#!/bin/bash

#SBATCH -n 1                  # Number of cores per node
#SBATCH -N 1                  # Number of nodes (keep at 1, except when using MPI queue)
#SBATCH -t 0-45:59            # Runtime in D-HH:MM format
#SBATCH -p medium             # Partition (queue)
#SBATCH -J indrop             # Job name
#SBATCH -o hostname_%j.out    # File to which STDOUT will be written, including job ID
#SBATCH -e hostname_%j.err    # File to which STDERR will be written, including job ID
#SBATCH --mem-per-cpu=8G      # Memory needed per core
#SBATCH --mail-type=ALL       # Type of email notification (BEGIN, END, FAIL, ALL)

bcbio_nextgen.py ../config/indrop_rnaseq.yaml -n 64 -t ipython -s slurm -q medium -r t=15:59
