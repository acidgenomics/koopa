# Divide by 4.
zcat *_R1.fastq.gz | \
    wc -l | \
    awk '{print $1/4}'
