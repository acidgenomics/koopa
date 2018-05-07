bcbio_nextgen.py -w template bcbio.yaml bcbio.csv *.fastq.gz

cd bcbio/work

# slurm
cp ../../sbatch_bcbio.sh .
sbatch submit_bcbio.sh
squeue -u $USER

less *.err
tree
