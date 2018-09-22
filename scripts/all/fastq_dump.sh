# FASTQ dump from SRA file requires sra-tools
# https://github.com/ncbi/sra-tools

command -v fastq-dump >/dev/null 2>&1 || {
    echo >&2 "fastq-dump missing"
    return 1
}

filelist="SRR_Acc_List.txt"

if [[ ! -f "$filelist" ]]; then
    echo "${filelist} does not exist"
    return 1
fi

# This loops across an SRA accession list.
# id: Accession ID.
# Note that this will skip FASTQ files that have already been extracted.
# This is useful because fastq-dump can take a long time and get interrupted.
while read id; do
    if [[ ! -f "${id}.fastq.gz" ]] && [[ ! -f "${id}_1.fastq.gz" ]]; then
        echo "SRA Accession: ${id}"
        fastq-dump --gzip --split-3 "${id}"
    fi
done < "$filelist"
unset -v filelist
