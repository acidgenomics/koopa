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
    # Recommended method until v4.3
    # export PATH="$CONDA_DIR/bin:$PATH"
    
    # New recommended method for v4.4
    . "$CONDA_DIR/etc/profile.d/conda.sh"
fi
