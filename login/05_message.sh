separator_bar="=================================================="

# Check for prompt string, SSH connection, and not on interactive node.
# Only show this message on the login node for HPC.
if [[ -n "$PS1" && -n "$SSH_CLIENT" && -z "$INTERACTIVE_QUEUE" ]]; then
    echo ""
    echo "$separator_bar"
    echo "koopa 🐢 v${KOOPA_VERSION} (${KOOPA_DATE})"
    echo "https://github.com/steinbaugh/koopa"
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
    echo "$separator_bar"
    echo ""
fi

unset -v separator_bar
