# Ideally, use symlinks with these defaults or you can rename
genomeDir="star"
genomeFastaFiles="genome.fasta"
sjdbGTFfile="genome.gtf"
if [ "$#" -gt "0" ]
then
    genomeDir="$1"
    genomeFastaFiles="$1"
    sjdbGTFfile="$2"
fi
if [ -d "$genomeDir" ]
then
    rm -rf "$genomeDir"
fi
mkdir -p "$genomeDir"
STAR --runMode=genomeGenerate --genomeDir="$genomeDir" --genomeFastaFiles="$fasta" --sjdbGTFfile="$gtf"
