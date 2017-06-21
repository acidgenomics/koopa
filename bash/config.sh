# orchestra
if [[ -n $ORCHESTRA ]]; then
    echo "HMS Orchestra modules ================================================="
    module list
fi

# conda
if [[ ! -z $CONDA_DIR ]]; then
    echo "conda ================================================================="
    conda --version
fi


# aspera connect
if [[ ! -z $ASPERA_DIR ]]; then
    echo "Aspera Connect ========================================================"
    ascp --version
fi


# bcbio-nextgen
if [[ ! -z $BCBIO_DIR ]]; then
    echo "bcbio-nextgen ========================================================="
    echo $BCBIO_DIR
fi
