# Build bcbio genome
#
# Caenorhabditis elegans
# 2018-03-16
#
# -c cores
# -f FASTA file
# -g GTF file
# -n organism name
# -b build name
c=8
f=Caenorhabditis_elegans.WBcel235.dna.toplevel.fa
g=Caenorhabditis_elegans.WBcel235.90.gtf
n=Celegans
b=WBcel235_90

srun -p interactive --pty -c $c --mem 8G --time 0-8:00 /bin/bash
cd /n/shared_db/bcbio/biodata
mkdir ${b}
cd ${b}

# FASTA
wget ftp://ftp.ensembl.org/pub/release-90/fasta/caenorhabditis_elegans/dna/${f}.gz
gunzip -c ${f}.gz > ${f}

# GTF
wget ftp://ftp.ensembl.org/pub/release-90/gtf/caenorhabditis_elegans/${g}.gz
gunzip -c ${g}.gz > ${g}

bcbio_setup_genome.py -c $c -f $f -g $g -i bowtie2 star seq -n $n -b $b
