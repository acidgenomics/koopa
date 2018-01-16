# This requires fastq-dump from sra-tools
# https://github.com/ncbi/sra-tools
command -v fastq-dump >/dev/null 2>&1 || { echo >&2 "fastq-dump missing"; exit 1; }

# Check for LSF
if [[ -z $LSF_ENVDIR ]]; then
    echo "LSF required"
    exit 1
fi

mkdir -p fastq
cd fastq
while read name; do
    if [[ ! -e $name.fastq.gz ]] && [[ ! -e $name_1.fastq.gz ]]; then
        echo "$name"
        bsub -q priority -W 6:00 fastq-dump --gzip --split-3 --accession "$name"
        # Remove SRA cache file upon completion
        rm ~/ncbi/public/sra/"$name".sra
    fi
done < ../SRR_Acc_List.txt
cd ..
