# FASTQ dump from SRA file requires sra-tools
# https://github.com/ncbi/sra-tools

command -v fastq-dump >/dev/null 2>&1 || {
    echo >&2 "fastq-dump missing"
    return 1
}

while read accession; do
    if [[ ! -e $accession.fastq.gz ]] && [[ ! -e $accession_1.fastq.gz ]]; then
        echo "$accession"
        fastq-dump --gzip --split-3 "$accession"
    fi
done < SRR_Acc_List.txt
