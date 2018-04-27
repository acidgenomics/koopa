# FASTQ dump from SRA file requires sra-tools
# https://github.com/ncbi/sra-tools

command -v fastq-dump >/dev/null 2>&1 || {
    echo >&2 "fastq-dump missing"
    return 1
}

while read name; do
    if [[ ! -e $name.fastq.gz ]] && [[ ! -e $name_1.fastq.gz ]]; then
        echo "$name"
        fastq-dump --gzip --split-3 --accession "$name"
    fi
done < SRR_Acc_List.txt
