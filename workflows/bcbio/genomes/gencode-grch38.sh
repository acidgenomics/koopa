#!/usr/bin/env bash
set -Eeuo pipefail

# GENCODE GRCh38 genome build
# Last updated 2019-03-19
# https://www.gencodegenes.org/releases/current.html
# https://www.gencodegenes.org/faq.html

# User-defined parameters ======================================================
biodata_dir="${HOME}/biodata"
# species="Homo_sapiens"
bcbio_species_dir="Hsapiens"
build="GRCh38"
source="GENCODE"
release="$GENCODE_HUMAN_RELEASE"
cores="$CPU_COUNT"

# GENCODE FTP files ============================================================
mkdir -p "$biodata_dir"
cd "$biodata_dir"
ftp_dir="ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_${release}"

# FASTA ------------------------------------------------------------------------
# Genome sequence, primary assembly
# GRCh38.primary_assembly.genome.fa.gz
fasta="${build}.primary_assembly.genome.fa"
wget "${ftp_dir}/${fasta}.gz"
gunzip -c "${fasta}.gz" > "$fasta"

# GTF --------------------------------------------------------------------------
# Comprehensive gene annotation
# gencode.v28.annotation.gtf.gz
gtf="gencode.v${release}.annotation.gtf"
wget "${ftp_dir}/${gtf}.gz"
gunzip -c "${gtf}.gz" > "$gtf"

# bcbio ========================================================================
bcbio_build_dir="${build}_${source}_${release}"
# bcbio_setup_genome.py --help
# Note that hisat2 requires a lot of memory to index.
bcbio_setup_genome.py \
    --build="$bcbio_build_dir" \
    --cores="$cores" \
    --fasta="$fasta" \
    --gtf="$gtf" \
    --name="$bcbio_species_dir" \
    --indexes hisat2

# Clean up =====================================================================
mkdir -p "$bcbio_build_dir"
mv "$fasta" "$bcbio_build_dir"
mv "$fasta.gz" "$bcbio_build_dir"
mv "$gtf" "$bcbio_build_dir"
mv "$gtf.gz" "$bcbio_build_dir"
