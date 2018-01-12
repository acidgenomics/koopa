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
echo "Last updated"
wd="$PWD"
cd "$SEQCLOUD_DIR"
git log -1 --format=%cd
cd "$wd"
unset -v wd
