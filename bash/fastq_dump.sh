# This requires fastq-dump from sra-tools
# https://github.com/ncbi/sra-tools
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
