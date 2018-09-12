# bcbio
if [[ -d "$BCBIO_DIR" ]]; then
    if [[ ! -f "${BCBIO_DIR}/bcbio_nextgen.py" ]]; then
        echo "bcbio_nextgen.py missing"
        return 1
    fi
    export PATH="${BCBIO_DIR}:${PATH}"
    unset -v PYTHONHOME PYTHONPATH
fi
