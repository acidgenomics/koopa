# PATH ====
echo "PATH exports"

# orchestra
if [[ -n $ORCHESTRA ]]; then
    echo "    [x] orchestra modules"
    module list
fi

# conda
if [[ ! -z $CONDA_DIR ]]; then
    echo "    [x] conda"
    conda --version
fi


# aspera connect
if [[ ! -z $ASPERA_DIR ]]; then
    echo "    [x] aspera connect"
    ascp --version
fi


# bcbio-nextgen
if [[ ! -z $BCBIO_DIR ]]; then
    echo "    [x] bcbio-nextgen"
    echo $BCBIO_DIR
fi
