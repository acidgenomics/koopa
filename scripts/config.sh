# bcbio
if [[ ! -z $BCBIO_DIR ]]; then
    echo "# bcbio"
    echo $BCBIO_DIR
fi

# Aspera Connect
if [[ ! -z $ASPERA_DIR ]]; then
    echo "# Aspera Connect"
    ascp --version
fi

# Conda
if [[ ! -z $CONDA_DIR ]]; then
    echo "# conda"
    conda --version
fi
