# Generate a genome index for kallisto
$fasta="$1"
if [ -d kallisto ]
then
    rm -rf kallisto
fi
mkdir kallisto
kallisto index --index=kallisto/transcripts.idx "$fasta"
unset fasta
