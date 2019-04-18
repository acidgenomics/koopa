#!/usr/bin/env bash
set -Eeuxo pipefail

# Ensembl GRCh37 genome build
# Last updated 2019-04-12
# https://grch37.ensembl.org/

# Build parameters =============================================================
build="GRCh37"
source="Ensembl"
release="87"

biodata_dir="${HOME}/biodata"
bcbio_species_dir="Hsapiens"

cores=$((CPU_COUNT-2))

# Prepare directories ==========================================================
mkdir -p "$biodata_dir"
cd "$biodata_dir"

bcbio_build_dir="${build}_${source}_${release}"
mkdir -p "$bcbio_build_dir"
cd "$bcbio_build_dir"

# Assembly files ===============================================================
ftp_dir="ftp://ftp.ensembl.org/pub/grch37/release-${release}"
species="Homo_sapiens"
species_lower=$(echo "$species" | tr '[:upper:]' '[:lower:]')

# FASTA ------------------------------------------------------------------------
# Primary assembly, unmasked
fasta="${species}.${build}.dna.primary_assembly.fa"
if [[ ! -f "$fasta" ]]
then
    wget "${ftp_dir}/fasta/${species_lower}/dna/${fasta}.gz"
    gunzip -c "${fasta}.gz" > "$fasta"
fi

# GTF --------------------------------------------------------------------------
gtf="${species}.${build}.${release}.gtf"
if [[ ! -f "$gtf" ]]
then
    wget "${ftp_dir}/gtf/${species_lower}/${gtf}.gz"
    gunzip -c "${gtf}.gz" > "$gtf"
fi

# bcbio ========================================================================
cd "$biodata_dir"

# Ensure there is a pinned version of cloudbiolinux in biodata directory.
[[ ! -d "cloudbiolinux" ]] && \
    echo "Need to clone cloudbiolinux" && \
    exit 1

log_dir="${HOME}/logs/${HOSTNAME}/bcbio"
mkdir -p "$log_dir"

fasta=$(realpath "${bcbio_build_dir}/${fasta}")

# Note use of clean GTF (see above).
gtf=$(realpath "${bcbio_build_dir}/${gtf}")

# bcbio_setup_genome.py --help

# Note that HISAT2 requires a lot of memory to index (>= 200 GB). This is
# intended to be run on a high performance cluster but is often impractical on
# a virtual machine instance (e.g. AWS, Azure).

bcbio_setup_genome.py \
    --build="$bcbio_build_dir" \
    --cores="$cores" \
    --fasta="$fasta" \
    --gtf="$gtf" \
    --name="$bcbio_species_dir" \
    --indexes bowtie2 minimap2 seq star \
    2>&1 | tee "${log_dir}/bcbio-genomes-$(date "+%Y%m%d_%H%M%S").log"
