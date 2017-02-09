RELEASE="87"
CDNA="$GENOME.cdna.all.fa"
DNA="$GENOME.dna.$FA_TYPE.fa"
GTF="$GENOME.$RELEASE.gtf"

if [ -d $MODEL ]; then
    rm -rf $MODEL
fi
mkdir $MODEL
cd $MODEL

# Download FASTA and GTF files:
wget ftp://ftp.ensembl.org/pub/release-$RELEASE/fasta/$MODEL/cdna/$CDNA.gz
wget ftp://ftp.ensembl.org/pub/release-$RELEASE/fasta/$MODEL/dna/$DNA.gz
wget ftp://ftp.ensembl.org/pub/release-$RELEASE/gtf/$MODEL/$GTF.gz

# Decompress the files:
gunzip -cf $CDNA.gz >$CDNA
gunzip -cf $DNA.gz >$DNA
gunzip -cf $GTF.gz >$GTF

ln -fs $CDNA cdna.fa
ln -fs $CDNA.gz cdna.fa.gz
ln -fs $DNA dna.fa
ln -fs $DNA.gz dna.fa.gz
ln -fs $GTF gtf
ln -fs $GTF.gz gtf.gz

ls -l
