# GENCODE GRCh38 genome build
# Last updated 2018-09-04
# https://www.gencodegenes.org/releases/current.html
# https://www.gencodegenes.org/faq.html

# User-defined parameters ======================================================
biodata_dir="$BIODATA_DIR"
species="Homo_sapiens"
bcbio_species_dir="Hsapiens"
build="GRCh38"
source="GENCODE"
release="$GENCODE_RELEASE"
cores="$CORES"

# GENCODE FTP files ============================================================
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
bcbio_setup_genome.py \
    --build="$bcbio_build_dir" \
    --cores="$cores" \
    --fasta="$fasta" \
    --gtf="$gtf" \
    --indexes="seq" \
    --indexes="star" \
    --indexes="hisat2" \
    --indexes="minimap2" \
    --name="$bcbio_species_dir"

# Clean up =====================================================================
mkdir -p "$bcbio_build_dir"
mv "$fasta" "$bcbio_build_dir"
mv "$fasta.gz" "$bcbio_build_dir"
mv "$gtf" "$bcbio_build_dir"
mv "$gtf.gz" "$bcbio_build_dir"
