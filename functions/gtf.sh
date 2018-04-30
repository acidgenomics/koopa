organism="$1"

ensembl="${ENSEMBL_RELEASE_URL}/gtf"

if [[ $organism == "hsapiens" ]]; then
    echo "Homo sapiens"
    echo "Ensembl GRCh38"
    remote="${ensembl}/homo_sapiens/Homo_sapiens.GRCh38.${ENSEMBL_RELEASE}.chr_patch_hapl_scaff.gtf.gz"
elif [[ $organism == "mmusculus" ]]; then
    echo "Mus musculus"
    echo "Ensembl GRCm38"
    remote="${ensembl}/mus_musculus/Mus_musculus.GRCm38.${ENSEMBL_RELEASE}.chr_patch_hapl_scaff.gtf.gz"
elif [[ $organism == "celegans" ]]; then
    # TODO Use WormBase instead of Ensembl?
    echo "Caenorhabditis elegans"
    echo "Ensembl WBcel235"
    remote="${ensembl}/caenorhabditis_elegans/Caenorhabditis_elegans.WBcel235.${ENSEMBL_RELEASE}.gtf.gz"
elif [[ $organism == "dmelanogaster" ]]; then
    # D. melanogaster Ensembl annotations are out of date.
    # Using the FlyBase annotations instead.
    echo "Drosophila melanogaster"
    echo "FlyBase ${FLYBASE_RELEASE_DATE} ${FLYBASE_RELEASE_VERSION}"
    remote="${FLYBASE_RELEASE_URL}/gtf/dmel-all-${FLYBASE_RELEASE_VERSION}.gtf.gz"
fi

wget "$remote"
local=$(basename "$remote")
gunzip -c "$local" > "${local%.*}"

unset -v ensembl local organism remote
