#!/bin/sh

## Start bcbio run on HMS O2 cluster using IPython and slurm.
## Updated 2019-07-09.

## Configure the bcbio run.
## A directory named "bcbio" will be created.
## SC2035: Use ./*glob* or -- *glob* so names with dashes won't become options.
bcbio_nextgen.py -w template bcbio.yaml bcbio.csv ./*.fastq.gz

## Traverse into the work directory.
(
    cd bcbio/work || exit 1
    ## Symlink our sbatch script.
    ln -s ../../sbatch-bcbio.sh .
    ## Now ready to start the run using slurm.
    sbatch sbatch_bcbio.sh
)

## This will check the run status.
squeue -u "$USER"
sshare -U

## Check the job status.
## > sprio -j JOBID
## > less *.err
## > tree
