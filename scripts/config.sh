# bcbio
if [[ ! -z $BCBIO_DIR ]]; then
    echo "# bcbio"
    echo $BCBIO_DIR
    echo ""
fi

# Conda
if [[ ! -z $CONDA_DIR ]]; then
    echo "# conda"
    conda --version
    echo ""
fi

# Date
git log -1 --format=%cd "$SEQCLOUD_DIR"
