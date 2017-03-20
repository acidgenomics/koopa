dataDir=/n/data1/cores/bcbio/PIs/XXX/XXX

fastq="$dataDir"/*_R[1-4].fastq.*
ls $fastq

workflow="indrop_rnaseq"
bcbio_nextgen.py -w template "$workflow".yaml "$workflow".csv $fastq

cd "$workflow"/work
cp "$seqcloudDir"/workflows/"$workflow"/submit_bcbio.lsf .
nano submit_bcbio.lsf

# bsub < submit_bcbio.lsf
