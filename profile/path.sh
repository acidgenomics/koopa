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
if [[ -n "$CONDA_VERSION" ]]; then
    if echo "$CONDA_VERSION" | grep -q "conda 4.3"; then
        export PATH="$CONDA_DIR/bin:$PATH"
    fi
fi
