if [[ "$#" -gt "0" ]]; then
    stem="$1"
else
    stem="lanepool"
fi

if test -n "$(find . -maxdepth 1 -name '*_L00[1-4]_*.fastq.gz' -print -quit)"; then
    cat *_L00[1-4]_R1_001.fastq.gz > "$stem"_R1.fastq.gz
    cat *_L00[1-4]_R2_001.fastq.gz > "$stem"_R2.fastq.gz
    cat *_L00[1-4]_R3_001.fastq.gz > "$stem"_R3.fastq.gz
    cat *_L00[1-4]_R4_001.fastq.gz > "$stem"_R4.fastq.gz
else
    echo "No lanesplit samples detected"
fi
