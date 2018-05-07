bcbio_nextgen.py -w template bcbio.yaml bcbio.csv *.fastq.gz

cd bcbio/work
cp ../../submit_bcbio.sh .
sbatch submit_bcbio.sh

squeue -u $USER
less *.err
tree
