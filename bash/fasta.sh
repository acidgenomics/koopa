# Drosophila melanogaster transcriptome FASTA
# Ensembl annotations are out of date (2014)
# Use the resources from FlyBase instead
organism="$1"
type="$2"
if [[ $organism == "dmelanogaster" ]]; then
    if [[ $type == "genome" ]]; then
        request="ftp://ftp.flybase.net/genomes/Drosophila_melanogaster/current/fasta/dmel-all-aligned-r6.14.fasta.gz"
    elif [[ $type == "transcriptome" ]]; then
        request="ftp://ftp.flybase.net/genomes/Drosophila_melanogaster/current/fasta/dmel-all-transcript-r6.14.fasta.gz"
    fi
fi
file=$(basename "$request")
wget "$request"
gunzip "$file"
ls -l *.fasta*
