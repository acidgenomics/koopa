# GENCODE GRCh37 mapped genome build
# Last updated 2018-08-21
# https://www.gencodegenes.org/releases/grch37_mapped_releases.html

wd="$PWD"

# User-defined parameters ======================================================
biodata_dir="${HOME}/biodata"
species="Homo_sapiens"
build="GRCh37"
source="GENCODE"
release="$GENCODE_RELEASE"
cores="8"

# Prepare directories ==========================================================
cd "$biodata_dir"

# Transform species name to lowercase.
# e.g. "homo_sapiens"
species_dir=$(echo "$species" | tr '[:upper:]' '[:lower:]')

# Prepare bcbio genome build directory name.
# e.g. "grch37_gencode_28"
build_dir="${build}_${source}_${release}"
build_dir=$(echo "$build_dir" | tr '[:upper:]' '[:lower:]')

# GENCODE FTP files ============================================================
ftp_dir="ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_${release}/${build}_mapping"

# FASTA ------------------------------------------------------------------------
# Genome sequence, primary assembly
# GRCh37.primary_assembly.genome.fa.gz
fasta="${build}.primary_assembly.genome.fa"
if [[ ! -f "$fasta" ]]; then
    wget "${ftp_dir}/${fasta}.gz"
    gunzip -c "${fasta}.gz" > "$fasta"
fi

# GTF --------------------------------------------------------------------------
# Comprehensive gene annotation
# gencode.v28lift37.annotation.gtf.gz
gtf="gencode.v${release}lift37.annotation.gtf"
if [[ ! -f "$gtf" ]]; then
    wget "${ftp_dir}/${gtf}.gz"
    gunzip -c "${gtf}.gz" > "$gtf"
fi

# bcbio ========================================================================
# Directory structure will be lower case.
# e.g. "bcbio/genomes/homo_sapiens/grch37_gencode_28"
bcbio_setup_genome.py \
    --build="$build_dir" \
    --cores="$cores" \
    --fasta="$fasta" \
    --gtf="$gtf" \
    --name="$species_dir" \
    -i seq star

cd "$wd"
