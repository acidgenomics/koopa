bcbio_nextgen.py -w template bcbio.yaml bcbio.csv *.fastq.gz

cd bcbio/work

# slurm
ln -s ../../sbatch_bcbio.sh .
sbatch sbatch_bcbio.sh
squeue -u $USER
sshare -U
# sprio -j JOBID
# less *.err
# tree
