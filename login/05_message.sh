separator_bar="=================================================="

# Check for prompt string, SSH connection, and not on interactive node.
# Only show this message on the login node for HPC.
if [[ -n "$PS1" && -n "$SSH_CLIENT" && -z "$INTERACTIVE_QUEUE" ]]; then
    echo ""
    echo "$separator_bar"
    echo "koopa 🐢 v${KOOPA_VERSION} (${KOOPA_DATE})"
    echo "https://github.com/steinbaugh/koopa"
    if [[ -d "$ASPERA_DIR" ]]; then
        echo ""
        echo "# Aspera Connect"
        readlink -f "$ASPERA_DIR"
        readlink -f $(which asperaconnect)
    fi
    if [[ -d "$BCBIO_DIR" ]]; then
        echo ""
        echo "# bcbio"
        readlink -f "$BCBIO_DIR"
        readlink -f $(which bcbio_nextgen.py)
    fi
    if [[ -d "$CONDA_DIR" ]]; then
        echo ""
        echo "# conda"
        readlink -f "$CONDA_DIR"
        readlink -f $(which conda)
    fi
    echo "$separator_bar"
    echo ""
fi

unset -v separator_bar
