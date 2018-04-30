# Prepare transcriptome FASTA and GTF from FlyBase
# 2018-04-30

url="$FLYBASE_RELEASE_URL"
version="$FLYBASE_RELEASE_VERSION"



# FASTA ========================================================================
wget ${url}/fasta/dmel-all-transcript-${version}.fasta.gz
wget ${url}/fasta/dmel-all-miRNA-${version}.fasta.gz
wget ${url}/fasta/dmel-all-miscRNA-${version}.fasta.gz
wget ${url}/fasta/dmel-all-ncRNA-${version}.fasta.gz
wget ${url}/fasta/dmel-all-pseudogene-${version}.fasta.gz
wget ${url}/fasta/dmel-all-tRNA-${version}.fasta.gz

# Concatenate into single transcriptome compressed FASTA
cat dmel-all-*-${version}.fasta.gz > dmel-transcriptome-${version}.fasta.gz

# Decompress but keep compressed copy
gunzip -c dmel-transcriptome-${version}.fasta.gz > \
    dmel-transcriptome-${version}.fasta

unset -v path



# GTF ==========================================================================
wget ${url}/gtf/dmel-all-${version}.gtf.gz

# Decompress but keep the original
gunzip -c dmel-all-${version}.gtf.gz > dmel-all-${version}.gtf



unset -v url version
