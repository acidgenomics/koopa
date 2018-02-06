# bcbio
if [[ -n "$BCBIO_DIR" ]]; then
    if [[ ! -f "$BCBIO_DIR/bcbio_nextgen.py" ]]; then
        echo "bcbio_nextgen.py missing"
        exit 1
    fi
    export PATH="$BCBIO_DIR:$PATH"
    unset -v PYTHONHOME PYTHONPATH
fi

# Aspera Connect
if [[ -n "$ASPERA_DIR" ]]; then
    export PATH="$ASPERA_DIR:$PATH"
fi

# conda
if [[ -n "$CONDA_DIR" ]]; then
    version=$($CONDA_DIR/bin/conda --version)
    if [[ grep "$version" "conda 4.4"]]; then
        . "$CONDA_DIR/etc/profile.d/conda.sh"
    elif [[ grep "$version" "conda 4.3"]]; then
        export PATH="$CONDA_DIR/bin:$PATH"
    else
        echo "$version is not supported"
        exit 1
    fi
fi
