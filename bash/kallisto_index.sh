if [ -d kallisto ]; then
    rm -rf kallisto
fi
mkdir kallisto
kallisto index --index=kallisto/transcripts.idx cdna.fa
