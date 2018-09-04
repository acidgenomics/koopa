# Ensembl GRCh38 genome build
# Last updated 2018-09-04
# https://ensembl.org

# User-defined parameters ======================================================
biodata_dir="$BIODATA_DIR"
species="Homo_sapiens"
bcbio_species_dir="Hsapiens"
build="GRCh38"
source="Ensembl"
release="$ENSEMBL_RELEASE"
cores="$CORES"

# Ensembl FTP files ============================================================
cd "$biodata_dir"
ftp_dir="ftp://ftp.ensembl.org/pub/release-${release}"
species_lower=$(echo "$species" | tr '[:upper:]' '[:lower:]')

# FASTA ------------------------------------------------------------------------
# Primary assembly, unmasked
# Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz
fasta="${species}.${build}.dna.primary_assembly.fa"
wget "${ftp_dir}/fasta/${species_lower}/dna/${fasta}.gz"
gunzip -c "${fasta}.gz" > "$fasta"

# GTF --------------------------------------------------------------------------
# Homo_sapiens.GRCh38.92.gtf.gz
gtf="${species}.${build}.${release}.gtf"
wget "${ftp_dir}/gtf/${species_lower}/${gtf}.gz"
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
