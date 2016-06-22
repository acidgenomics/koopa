if [ ! -d fastq ]; then
  mkdir fastq
fi
cd fastq
while read name; do
  if [ ! -e "${name}.fastq.gz" ] && [ ! -e "${name}_1.fastq.gz" ]; then
    echo "${name}"
    bsub -q priority -W 6:00 fastq-dump --gzip --split-3 --accession "${name}"
    # rm ~/ncbi/public/sra/{$name}.sra # Clean the SRA cache
  fi
done < ../SRR_Acc_List.txt
