#!/usr/bin/env bash
set -Eeuo pipefail

# Ensembl GRCh37 genome build
# Last updated 2019-04-10
# https://grch37.ensembl.org/

# User-defined parameters ======================================================
biodata_dir="${HOME}/biodata"
mkdir -p "$biodata_dir"
cd "$biodata_dir"

# Build parameters =============================================================
species="Homo_sapiens"
build="GRCh37"
source="Ensembl"
release="87"

bcbio_species_dir="Hsapiens"
bcbio_build_dir="${build}_${source}_${release}"

cores="$CPU_COUNT"

mkdir -p "$bcbio_build_dir"
cd "$bcbio_build_dir"

# Assemlbly files ==============================================================
cd "$biodata_dir"
ftp_dir="ftp://ftp.ensembl.org/pub/grch37/release-${release}"
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
# bcbio_setup_genome.py --help
# Note that hisat2 requires a lot of memory to index.
bcbio_setup_genome.py \
    --build="$bcbio_build_dir" \
    --cores="$cores" \
    --fasta="$fasta" \
    --gtf="$gtf" \
    --name="$bcbio_species_dir" \
    --indexes bowtie2 hisat2 minimap2 seq star

# Clean up =====================================================================
mkdir -p "$bcbio_build_dir"
mv "$fasta" "$bcbio_build_dir"
mv "$fasta.gz" "$bcbio_build_dir"
mv "$gtf" "$bcbio_build_dir"
mv "$gtf.gz" "$bcbio_build_dir"
