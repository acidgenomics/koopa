# This assumes the following data structure:
# - fastq
# - genome (STAR genome dir, preferable to symlink)
# - sam

# Check for STAR
command -v STAR >/dev/null 2>&1 || { echo >&2 "STAR missing"; return 1; }

# Check for LSF
if [[ -z $LSF_ENVDIR ]]; then
    echo "LSF required"
fi

# User-defined parameters
if [[ "$#" -gt "0" ]]; then
    queue="$1"
    cores="$2"
    genome_dir="$3"
else
    queue="mcore"
    cores="12"
    # Also adjust the memory settings here for Orchesta recommendation
    # Could default to 2 core, 16 GB RAM
    genome_dir="star"
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
            # FIXME These settings are optimized for *C. elegans*
            bsub -q "$queue" -W 1:00 -n "$cores" \
                STAR --genome_dir="$genome_dir"/ \
                     --outFileNamePrefix=sam/"$base"/ \
                     --readFilesCommand=zcat \
                     --readFilesIn="$fastq" \
                     --runThreadN="$cores" \
                     --outFilterType=BySJout \
                     --outFilterMultimapNmax=20 \
                     --alignSJoverhangMin=8 \
                     --alignSJDBoverhangMin=1 \
                     --outFilterMismatchNmax=999 \
                     --alignIntronMin=20 \
                     --alignIntronMax=1000000 \
                     --alignMatesGapMax=1000000
        fi
    fi
done
cd ../
