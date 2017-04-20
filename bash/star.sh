# This assumes the following data structure:
# - fastq
# - genome (STAR genome dir, preferable to symlink)
# - sam
queue="mcore"
cores="12"
# Also adjust the memory settings here for Orchesta recommendation
# Could default to 2 core, 16 GB RAM
genome_dir="star"
if [[ "$#" -gt "0" ]]; then
    queue="$1"
    cores="$2"
    genome_dir="$3"
fi
for fastq in $(ls fastq/*.fastq.gz); do
    base=$(basename "$fastq" .fastq.gz)
    # Skip second paired file in loop for simplicity
    if [[ ! "$base" == *"_2" ]]; then
        if [[ "$base" == *"_1" ]]; then
            base=$(basename "$base" _1)
            echo "$base (paired)"
            fastq="fastq/${base}_1.fastq.gz fastq/${base}_2.fastq.gz"
        else
            echo "$base (single)"
        fi
        if [ ! -d sam/"$base" ]; then
            mkdir -p sam/"$base"
            bsub -q "$queue" -W 1:00 -n "$cores" STAR --genome_dir="$genome_dir"/ --outFileNamePrefix=sam/"$base"/ --readFilesCommand=zcat --readFilesIn="$fastq" --runThreadN="$cores" --outFilterType=BySJout --outFilterMultimapNmax=20 --alignSJoverhangMin=8 --alignSJDBoverhangMin=1 --outFilterMismatchNmax=999 --alignIntronMin=20 --alignIntronMax=1000000 --alignMatesGapMax=1000000
        fi
    fi
done
cd ../
