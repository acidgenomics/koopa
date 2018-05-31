# conda
if [[ -n "$CONDA_VERSION" ]]; then
    if echo "$CONDA_VERSION" | grep -q "conda 4.3"; then
        export PATH="${CONDA_DIR}/bin:${PATH}"
    fi
fi
