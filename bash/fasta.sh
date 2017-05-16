organism="$1"
type="$2"

if [[ $organism == "hsapiens" ]]; then
    echo "Homo sapiens"
    echo "Ensembl GRCh38"
    if [[ $type == "dna" ]]; then
        request="ftp://ftp.ensembl.org/pub/current_fasta/homo_sapiens/dna/Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz"
    elif [[ $type == "cdna" ]]; then
        request="ftp://ftp.ensembl.org/pub/current_fasta/homo_sapiens/cdna/Homo_sapiens.GRCh38.cdna.all.fa.gz"
    fi
elif [[ $organism == "mmusculus" ]]; then
    echo "Mus musculus"
    echo "Ensembl GRCm38"
    if [[ $type == "dna" ]]; then
        request="ftp://ftp.ensembl.org/pub/current_fasta/mus_musculus/dna/Mus_musculus.GRCm38.dna.primary_assembly.fa.gz"
    elif [[ $type == "cdna" ]]; then
        request="ftp://ftp.ensembl.org/pub/current_fasta/mus_musculus/cdna/Mus_musculus.GRCm38.cdna.all.fa.gz"
    fi
elif [[ $organism == "celegans" ]]; then
    # Use WormBase annotations instead of Ensembl?
    echo "Caenorhabditis elegans"
    echo "Ensembl WBcel235"
    if [[ $type == "dna" ]]; then
        # request="ftp://ftp.wormbase.org/pub/wormbase/species/c_elegans/sequence/genomic/c_elegans.canonical_bioproject.current.genomic.fa.gz"
        request="ftp://ftp.ensembl.org/pub/current_fasta/caenorhabditis_elegans/dna/Caenorhabditis_elegans.WBcel235.dna.toplevel.fa.gz"
    elif [[ $type == "cdna" ]]; then
        # request="ftp://ftp.wormbase.org/pub/wormbase/species/c_elegans/sequence/transcripts/c_elegans.canonical_bioproject.current.mRNA_transcripts.fa.gz"
        request="ftp://ftp.ensembl.org/pub/current_fasta/caenorhabditis_elegans/cdna/Caenorhabditis_elegans.WBcel235.cdna.all.fa.gz"
    fi
elif [[ $organism == "dmelanogaster" ]]; then
    # D. melanogaster Ensembl annotations are out of date (2014).
    # Use the FlyBase annotations instead.
    echo "Drosophila melanogaster"
    echo "FlyBase r6.15"
    if [[ $type == "dna" ]]; then
        request="ftp://ftp.flybase.net/genomes/Drosophila_melanogaster/current/fasta/dmel-all-aligned-r6.15.fasta.gz"
    elif [[ $type == "cdna" ]]; then
        request="ftp://ftp.flybase.net/genomes/Drosophila_melanogaster/current/fasta/dmel-all-transcript-r6.15.fasta.gz"
    fi
elif [[ $organism == "nfurzeri" ]]; then
    echo "Nothobranchius furzeri (turquoise killifish)"
    echo "NFINgb GRZ Assembly"
    if [[ $type == "dna" ]]; then
        # $request="http://africanturquoisekillifishbrowser.org/NotFur1_genome_draft.fa.tar.gz"
        request="http://nfingb.leibniz-fli.de/data/raw/notho4/Nfu_20150522.softmasked_genome.fa.gz"
    elif [[ $type == "cdna" ]]; then
        request="http://nfingb.leibniz-fli.de/data/raw/notho4/Nfu_20150522.genes_20150922.transcripts.fa.gz"
    fi
fi

wget "$request"
fasta=$(basename "$request")
gunzip "$fasta"
ls -l *.fa

unset request
unset type
