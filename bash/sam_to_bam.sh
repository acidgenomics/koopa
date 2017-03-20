for file in $(cat files); do
    samtools view -bS aligned/"$file".Aligned.out.sam -o aligned/"$file".bam;
done
