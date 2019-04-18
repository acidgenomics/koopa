#!/usr/bin/env bash
set -Eeuxo pipefail

# RefSeq GRCh38 genome build
# Last updated 2019-04-12
# https://www.ncbi.nlm.nih.gov/refseq/

# Build parameters =============================================================
build="GRCh38"
source="RefSeq"
release="$REFSEQ_RELEASE"

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
assembly="GCF_000001405.38_GRCh38.p12"
ftp_dir="ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/001/405/${assembly}"

# MD5 checksums ----------------------------------------------------------------
if [[ ! -f "md5checksums.txt" ]]
then
    wget "${ftp_dir}/md5checksums.txt"
fi

# FASTA ------------------------------------------------------------------------
fasta="${assembly}_genomic.fna"
if [[ ! -f "$fasta" ]]
then
    wget "${ftp_dir}/${fasta}.gz"
    gunzip -c "${fasta}.gz" > "$fasta"
fi

# GTF --------------------------------------------------------------------------
gtf="${assembly}_genomic.gtf"
if [[ ! -f "$gtf" ]]
then
    wget "${ftp_dir}/${gtf}.gz"
    gunzip -c "${gtf}.gz" > "$gtf"
fi

# Sanitize GTF =================================================================
# Note that we're using a sanitized GTF here, otherwise bowtie2 index will fail.
cp "$gtf" tmp-01-original.gtf

# RefSeq GTF contains trailing whitespace characters.
cp tmp-01-original.gtf tmp-02-clean-whitespace.gtf
sed -i 's/[[:blank:]]*$//' tmp-02-clean-whitespace.gtf

# Remove invalid biotypes that will cause UCSC gtfToGenePred to fail.
grep -vwE "(start_codon|stop_codon|unknown_transcript_1)" tmp-02-clean-whitespace.gtf > tmp-03-clean-biotypes.gtf

clean_gtf="${assembly}_genomic-clean.gtf"
cp tmp-03-clean-biotypes.gtf "$clean_gtf"

# Check that everything's kosher.
grep -q '[[:blank:]]$' "$clean_gtf" && \
    echo "GTF failure: trailing whitespace" && \
    exit 1
grep -q 'start_codon' "$clean_gtf" && \
    echo "GTF failure: start_codon" && \
    exit 1
grep -q 'stop_codon' "$clean_gtf" && \
    echo "GTF failure: stop_codon" && \
    exit 1
grep -c 'unknown_transcript_1' "$clean_gtf" && \
    echo "GTF failure: unknown_transcript_1" && \
    exit 1

# Return the number of lines per GTF file.
# wc -l *.gtf

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
gtf=$(realpath "${bcbio_build_dir}/${clean_gtf}")

# bcbio_setup_genome.py --help

# Note that HISAT2 requires a lot of memory to index (>= 200 GB). This is
# intended to be run on a high performance cluster but is often impractical on
# a virtual machine instance (e.g. AWS, Azure).

bcbio_setup_genome.py \
    --cores="$cores" \
    --name="$bcbio_species_dir" \
    --build="$bcbio_build_dir" \
    --fasta="$fasta" \
    --gtf="$gtf" \
    --indexes bowtie2 minimap2 seq star \
    2>&1 | tee "${log_dir}/bcbio-genomes-$(date "+%Y%m%d_%H%M%S").log"
