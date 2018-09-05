# GENCODE GRCh37 mapped genome build
# Last updated 2018-09-05
# https://www.gencodegenes.org/releases/grch37_mapped_releases.html

# User-defined parameters ======================================================
biodata_dir="$BIODATA_DIR"
species="Homo_sapiens"
bcbio_species_dir="Hsapiens"
build="GRCh37"
source="GENCODE"
release="$GENCODE_RELEASE"
cores="$CORES"

# GENCODE FTP files ============================================================
cd "$biodata_dir"
ftp_dir="ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_${release}/${build}_mapping"

# FASTA ------------------------------------------------------------------------
# Genome sequence, primary assembly
# GRCh37.primary_assembly.genome.fa.gz
fasta="${build}.primary_assembly.genome.fa"
wget "${ftp_dir}/${fasta}.gz"
gunzip -c "${fasta}.gz" > "$fasta"

# GTF --------------------------------------------------------------------------
# Comprehensive gene annotation
# gencode.v28lift37.annotation.gtf.gz
gtf="gencode.v${release}lift37.annotation.gtf"
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
    --indexes star minimap2

# Clean up =====================================================================
mkdir -p "$bcbio_build_dir"
mv "$fasta" "$bcbio_build_dir"
mv "$fasta.gz" "$bcbio_build_dir"
mv "$gtf" "$bcbio_build_dir"
mv "$gtf.gz" "$bcbio_build_dir"
