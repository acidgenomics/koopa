# HMS RC
if [[ $HPC =~ "HMS RC" ]]; then
    echo "Modules ==============================================================="
    module list
fi

# Conda
if [[ ! -z $CONDA_DIR ]]; then
    echo "Conda ================================================================="
    conda --version
fi

# Aspera Connect
if [[ ! -z $ASPERA_DIR ]]; then
    echo "Aspera Connect ========================================================"
    ascp --version
fi

# bcbio-nextgen
if [[ ! -z $BCBIO_DIR ]]; then
    echo "bcbio-nextgen ========================================================="
    echo $BCBIO_DIR
fi
