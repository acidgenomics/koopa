#!/bin/bash

#SBATCH -n 12                 # Number of cores per node
#SBATCH -N 1                  # Number of nodes (keep at 1, except when using MPI queue)
#SBATCH -t 2-00:00            # Runtime in D-HH:MM format
#SBATCH -p medium             # Partition (queue)
#SBATCH -J cellranger         # Job name
#SBATCH -o project_%j.out    # File to which STDOUT will be written, including job ID
#SBATCH -e project_%j.err    # File to which STDERR will be written, including job ID
#SBATCH --mem-per-cpu=8G      # Memory needed per core
#SBATCH --mail-type=ALL       # Type of email notification (BEGIN, END, FAIL, ALL)

bash cellranger.sh
