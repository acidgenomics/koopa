if [[ "$#" -gt "0" ]]; then
    stem="$1"
else
    stem="lanepool"
fi
cat *_R1_001.fastq.gz > "$stem"_R1.fastq.gz
cat *_R2_001.fastq.gz > "$stem"_R2.fastq.gz
cat *_R3_001.fastq.gz > "$stem"_R3.fastq.gz
cat *_R4_001.fastq.gz > "$stem"_R4.fastq.gz
