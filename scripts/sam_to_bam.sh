command -v samtools >/dev/null 2>&1 || { echo >&2 "samtools missing"; return 1; }
for file in $(cat files); do
    samtools view -bS aligned/"$file".Aligned.out.sam -o aligned/"$file".bam;
done
