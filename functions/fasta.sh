organism="$1"
type="$2"

# Default to Ensembl
base_url="${ENSEMBL_RELEASE_URL}/fasta"

# Warn on transcriptome usage
if [[ $type == "transcriptome" ]]; then
    echo "Use `cdna` instead of `transcriptome`"
    type="cdna"
fi

if [[ $organism == "hsapiens" ]]; then
    echo "Homo sapiens"
    echo "Ensembl GRCh38"
    if [[ $type == "dna" ]]; then
        remote="${base_url}/homo_sapiens/dna/Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz"
    elif [[ $type == "cdna" ]]; then
        remote="${base_url}/homo_sapiens/cdna/Homo_sapiens.GRCh38.cdna.all.fa.gz"
    fi
elif [[ $organism == "mmusculus" ]]; then
    echo "Mus musculus"
    echo "Ensembl GRCm38"
    if [[ $type == "dna" ]]; then
        remote="${base_url}/mus_musculus/dna/Mus_musculus.GRCm38.dna.primary_assembly.fa.gz"
    elif [[ $type == "cdna" ]]; then
        remote="${base_url}/mus_musculus/cdna/Mus_musculus.GRCm38.cdna.all.fa.gz"
    fi
elif [[ $organism == "celegans" ]]; then
    # TODO Use WormBase instead of Ensembl?
    echo "Caenorhabditis elegans"
    echo "Ensembl WBcel235"
    if [[ $type == "dna" ]]; then
        remote="${base_url}/caenorhabditis_elegans/dna/Caenorhabditis_elegans.WBcel235.dna.toplevel.fa.gz"
        # remote="ftp://ftp.wormbase.org/pub/wormbase/species/c_elegans/sequence/genomic/c_elegans.canonical_bioproject.current.genomic.fa.gz"
    elif [[ $type == "cdna" ]]; then
        remote="${base_url}/caenorhabditis_elegans/cdna/Caenorhabditis_elegans.WBcel235.cdna.all.fa.gz"
        # remote="ftp://ftp.wormbase.org/pub/wormbase/species/c_elegans/sequence/transcripts/c_elegans.canonical_bioproject.current.mRNA_transcripts.fa.gz"
    fi
elif [[ $organism == "dmelanogaster" ]]; then
    # D. melanogaster Ensembl annotations are out of date.
    # Using the FlyBase annotations instead.
    echo "Drosophila melanogaster"
    echo "FlyBase ${FLYBASE_RELEASE_DATE} ${FLYBASE_RELEASE_VERSION}"
    
    base_url="$FLYBASE_RELEASE_URL/fasta"
    version="$FLYBASE_RELEASE_VERSION"
    
    if [[ $type == "dna" ]]; then
        remote="${base_url}/dmel-all-aligned-${version}.fasta.gz"
    elif [[ $type == "cdna" ]]; then
        wget "${base_url}/dmel-all-transcript-${version}.fasta.gz"
        wget "${base_url}/dmel-all-miRNA-${version}.fasta.gz"
        wget "${base_url}/dmel-all-miscRNA-${version}.fasta.gz"
        wget "${base_url}/dmel-all-ncRNA-${version}.fasta.gz"
        wget "${base_url}/dmel-all-pseudogene-${version}.fasta.gz"
        wget "${base_url}/dmel-all-tRNA-${version}.fasta.gz"

        # Concatenate into single FASTA
        file=dmel-transcriptome-${version}.fasta.gz
        cat dmel-all-*-${version}.fasta.gz > $file

        download=false
        unset -v version
    fi
elif [[ $organism == "nfurzeri" ]]; then
    echo "Nothobranchius furzeri (turquoise killifish)"
    echo "NFINgb GRZ Assembly"
    base_url="http://nfingb.leibniz-fli.de/data/raw/notho4"
    if [[ $type == "dna" ]]; then
        remote="${base_url}/Nfu_20150522.softmasked_genome.fa.gz"
        # $remote="http://africanturquoisekillifishbrowser.org/NotFur1_genome_draft.fa.tar.gz"
    elif [[ $type == "cdna" ]]; then
        remote="${base_url}/Nfu_20150522.genes_20150922.transcripts.fa.gz"
    fi
fi

if [[ -n $remote ]]; then
    echo "$remote"
    wget "$remote"
    file=$(basename "$remote")
fi

# Decompress but keep compressed copy
gunzip -c "$file" > "${file%.*}"

unset -v base_url download file organism remote type
