if [[ -n "$PS1" && -n "$HPC" && -z "$INTERACTIVE_QUEUE" ]]; then
    echo ""
    echo "==== seqcloud ============================================================="
    echo "http://seq.cloud"
    if [[ -d "$ASPERA_DIR" ]]; then
        echo "# Aspera Connect"
        echo "$ASPERA_DIR"
    fi
    if [[ -d "$BCBIO_DIR" ]]; then
        echo "# bcbio"
        echo "$BCBIO_DIR"
    fi
    if [[ -d "$CONDA_DIR" ]]; then
        echo "# conda"
        echo "$CONDA_DIR"
    fi
    echo "==========================================================================="
fi
