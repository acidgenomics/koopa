#!/usr/bin/env bash
set -Eeuo pipefail

# Ensembl GRCh38 genome build
# Last updated 2019-03-19
# https://ensembl.org/

# User-defined parameters ======================================================
biodata_dir="${HOME}/biodata"
species="Homo_sapiens"
bcbio_species_dir="Hsapiens"
build="GRCh38"
source="Ensembl"
release="$ENSEMBL_RELEASE"
cores="$CPU_COUNT"

# Ensembl FTP files ============================================================
cd "$biodata_dir"
ftp_dir="ftp://ftp.ensembl.org/pub/release-${release}"
species_lower=$(echo "$species" | tr '[:upper:]' '[:lower:]')

# FASTA ------------------------------------------------------------------------
# Primary assembly, unmasked
fasta="${species}.${build}.dna.primary_assembly.fa"
wget "${ftp_dir}/fasta/${species_lower}/dna/${fasta}.gz"
gunzip -c "${fasta}.gz" > "$fasta"

# GTF --------------------------------------------------------------------------
gtf="${species}.${build}.${release}.gtf"
wget "${ftp_dir}/gtf/${species_lower}/${gtf}.gz"
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
    --indexes bowtie2 hisat2 minimap2 star

# Clean up =====================================================================
mkdir -p "$bcbio_build_dir"
mv "$fasta" "$bcbio_build_dir"
mv "$fasta.gz" "$bcbio_build_dir"
mv "$gtf" "$bcbio_build_dir"
mv "$gtf.gz" "$bcbio_build_dir"
