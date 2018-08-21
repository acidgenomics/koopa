# Ensembl GRCh37 genome build
# Last updated 2018-08-21
# https://grch37.ensembl.org

wd="$PWD"

# User-defined parameters ======================================================
biodata_dir="${HOME}/biodata"
species="Homo_sapiens"
build="GRCh37"
source="Ensembl"
release="87"
cores="8"

# Prepare directories ==========================================================
cd "$biodata_dir"

# Transform species name to lowercase.
# e.g. "homo_sapiens"
species_dir=$(echo "$species" | tr '[:upper:]' '[:lower:]')

# Prepare bcbio genome build directory name.
# e.g. "grch37_ensembl_87"
build_dir="${build}_${source}_${release}"
build_dir=$(echo "$build_dir" | tr '[:upper:]' '[:lower:]')

# Ensembl FTP files ============================================================
ftp_dir="ftp://ftp.ensembl.org/pub/grch37/release-${release}"

# FASTA ------------------------------------------------------------------------
# Primary assembly, unmasked
# Homo_sapiens.GRCh37.dna.primary_assembly.fa.gz
fasta="${species}.${build}.dna.primary_assembly.fa"
if [[ ! -f "$fasta" ]]; then
    wget "${ftp_dir}/fasta/${species_dir}/dna/${fasta}.gz"
    gunzip -c "${fasta}.gz" > "$fasta"
fi

# GTF --------------------------------------------------------------------------
# Homo_sapiens.GRCh37.87.gtf.gz
gtf="${species}.${build}.${release}.gtf"
if [[ ! -f "$gtf" ]]; then
    wget "${ftp_dir}/gtf/${species_dir}/${gtf}.gz"
    gunzip -c "${gtf}.gz" > "$gtf"
fi

# bcbio ========================================================================
# Directory structure will be lower case.
# e.g. "bcbio/genomes/homo_sapiens/grch37_ensembl_87"
bcbio_setup_genome.py \
    --build="$build_dir" \
    --cores="$cores" \
    --fasta="$fasta" \
    --gtf="$gtf" \
    --name="$species_dir" \
    -i seq star

cd "$wd"
