# Ideally, use symlinks with these defaults or you can rename
if [[ "$#" -gt "0" ]]; then
    genome_dir="$1"
    fasta="$1"
    gtf="$2"
else
    genome_dir="star"
    fasta="genome.fasta"
    gtf="genome.gtf"
fi
if [[ -d "$genome_dir" ]]; then
    rm -rf "$genome_dir"
fi
mkdir -p "$genome_dir"
STAR --runMode=genomeGenerate --genome_dir="$genome_dir" --genomeFastaFiles="$fasta" --sjdbGTFfile="$gtf"
