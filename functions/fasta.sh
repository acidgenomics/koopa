organism="$1"
type="$2"

ensembl="${ENSEMBL_RELEASE_URL}/fasta"
download=true

# Warn on transcriptome usage
if [[ $type == "transcriptome" ]]; then
    echo "Use `cdna` instead of `transcriptome`"
    type="cdna"
fi

if [[ $organism == "hsapiens" ]]; then
    echo "Homo sapiens"
    echo "Ensembl GRCh38"
    if [[ $type == "dna" ]]; then
        remote="${ensembl}/homo_sapiens/dna/Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz"
    elif [[ $type == "cdna" ]]; then
        remote="${ensembl}/homo_sapiens/cdna/Homo_sapiens.GRCh38.cdna.all.fa.gz"
    fi
elif [[ $organism == "mmusculus" ]]; then
    echo "Mus musculus"
    echo "Ensembl GRCm38"
    if [[ $type == "dna" ]]; then
        remote="${ensembl}/mus_musculus/dna/Mus_musculus.GRCm38.dna.primary_assembly.fa.gz"
    elif [[ $type == "cdna" ]]; then
        remote="${ensembl}/mus_musculus/cdna/Mus_musculus.GRCm38.cdna.all.fa.gz"
    fi
elif [[ $organism == "celegans" ]]; then
    # TODO Use WormBase instead of Ensembl?
    echo "Caenorhabditis elegans"
    echo "Ensembl WBcel235"
    if [[ $type == "dna" ]]; then
        # remote="ftp://ftp.wormbase.org/pub/wormbase/species/c_elegans/sequence/genomic/c_elegans.canonical_bioproject.current.genomic.fa.gz"
        remote="${ensembl}/caenorhabditis_elegans/dna/Caenorhabditis_elegans.WBcel235.dna.toplevel.fa.gz"
    elif [[ $type == "cdna" ]]; then
        # remote="ftp://ftp.wormbase.org/pub/wormbase/species/c_elegans/sequence/transcripts/c_elegans.canonical_bioproject.current.mRNA_transcripts.fa.gz"
        remote="${ensembl}/caenorhabditis_elegans/cdna/Caenorhabditis_elegans.WBcel235.cdna.all.fa.gz"
    fi
elif [[ $organism == "dmelanogaster" ]]; then
    # D. melanogaster Ensembl annotations are out of date (2014).
    # Using the FlyBase annotations instead.
    echo "Drosophila melanogaster"
    echo "FlyBase ${FLYBASE_RELEASE_DATE} ${FLYBASE_RELEASE_VERSION}"
    flybase="${FLYBASE_RELEASE_URL}/fasta"
    if [[ $type == "dna" ]]; then
        remote="${flybase}/dmel-all-aligned-${FLYBASE_RELEASE_VERSION}.fasta.gz"
    elif [[ $type == "cdna" ]]; then
        echo "HELLO WORLD"
        seqcloud flybase_transcriptome
        download=false
    fi
elif [[ $organism == "nfurzeri" ]]; then
    echo "Nothobranchius furzeri (turquoise killifish)"
    echo "NFINgb GRZ Assembly"
    nfingb="http://nfingb.leibniz-fli.de/data/raw/notho4"
    if [[ $type == "dna" ]]; then
        # $remote="http://africanturquoisekillifishbrowser.org/NotFur1_genome_draft.fa.tar.gz"
        remote="${nfingb}/Nfu_20150522.softmasked_genome.fa.gz"
    elif [[ $type == "cdna" ]]; then
        remote="${nfingb}/Nfu_20150522.genes_20150922.transcripts.fa.gz"
    fi
fi

if [[ $download == true ]]; then
    echo $remote
    wget "$remote"
    local=$(basename "$remote")
    gunzip -c "$local" > "${local%.*}"
fi

unset -v download ensembl local organism remote type
