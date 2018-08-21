# Ensembl GRCh38 genome build
# Last updated 2018-08-21

# User-defined parameters ======================================================
biodata_dir="${HOME}/biodata"
species="Homo_sapiens"
build="GRCh38"
source="Ensembl"
release=$ENSEMBL_RELEASE
cores=8

# Prepare build directory ======================================================
cd "$biodata_dir"
# e.g. grch38_ensembl_92
build_dir="${build}_${source}_${release}"
build_dir=$(echo "$build_dir" | tr '[:upper:]' '[:lower:]')
mkdir -p "$build_dir"
cd "$build_dir"

# Transform species name to lowercase
species_dir=$(echo "$species" | tr '[:upper:]' '[:lower:]')

# Ensembl FTP files ============================================================
# FASTA ------------------------------------------------------------------------
# Primary assembly, unmasked
# Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz
fasta="${species}.${build}.dna.primary_assembly.fa"
if [[ ! -f "$fasta" ]]; then
    wget "ftp://ftp.ensembl.org/pub/release-${release}/fasta/${species_dir}/dna/${fasta}.gz"
    gunzip -c "${fasta}.gz" > "$fasta"
fi

# GTF --------------------------------------------------------------------------
# Homo_sapiens.GRCh38.92.gtf.gz
gtf="${species}.${build}.${release}.gtf"
if [[ ! -f "$gtf" ]]; then
    wget "ftp://ftp.ensembl.org/pub/release-${release}/gtf/${species_dir}/${gtf}.gz"
    gunzip -c "${gtf}.gz" > "$gtf"
fi

# bcbio ========================================================================
# -b --build
# -c --cores
# -f --fasta
# -g --gtf
# -n --name (species)
bcbio_setup_genome.py \
    --build "$build_dir" \
    --cores "$cores" \
    --fasta "$fasta" \
    --gtf "$gtf" \
    --indexes seq star \
    --name "$species" \
