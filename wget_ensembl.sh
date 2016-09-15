RELEASE="85"
CDNA="$GENOME.cdna.all.fa"
DNA="$GENOME.dna.$FA_TYPE.fa"
GTF="$GENOME.$RELEASE.gtf"

cd ~/data
if [ ! -d $MODEL ]; then
    mkdir $MODEL
fi
cd $MODEL
if [ -d genome ]; then
    rm -rf genome
fi
mkdir genome
cd genome

# Download FASTA and GTF files
if [ ! -f $CDNA.gz ]; then
    wget ftp://ftp.ensembl.org/pub/release-$RELEASE/fasta/$MODEL/cdna/$CDNA.gz
fi
if [ ! -f $DNA.gz ]; then
    wget ftp://ftp.ensembl.org/pub/release-$RELEASE/fasta/$MODEL/dna/$DNA.gz
fi
if [ ! -f $GTF.gz ]; then
    wget ftp://ftp.ensembl.org/pub/release-$RELEASE/gtf/$MODEL/$GTF.gz
fi

# Decompress the files if necessary
if [ ! -f $CDNA ]; then
    gunzip -cf $CDNA.gz >$CDNA
fi
if [ ! -f $DNA ]; then
    gunzip -cf $DNA.gz >$DNA
fi
if [ ! -f $GTF ]; then
    gunzip -cf $GTF.gz >$GTF
fi

ln -fs $CDNA cdna.fa
ln -fs $CDNA.gz cdna.fa.gz
ln -fs $DNA dna.fa
ln -fs $DNA.gz dna.fa.gz
ln -fs $GTF gtf
ln -fs $GTF.gz gtf.gz

ls -l
