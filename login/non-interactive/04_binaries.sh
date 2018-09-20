# Export PATH string.

# General ======================================================================
# User specific environment and startup programs.
# ~/.local/bin
if [[ -d "${HOME}/.local/bin" ]]; then
    export PATH="${PATH}:${HOME}/.local/bin"
fi
# ~/bin
if [[ -d "${HOME}/.local/bin" ]]; then
    export PATH="${PATH}:${HOME}/bin"
fi

# Aspera Connect ===============================================================
if [[ -z "$ASPERA_DIR" ]]; then
    aspera_dir="${HOME}/.aspera/connect/bin"
    if [[ -d "$aspera_dir" ]]; then
        export ASPERA_DIR="$aspera_dir"
    fi
    unset -v aspera_dir
fi
if [[ -d "$ASPERA_DIR" ]]; then
    export PATH="${ASPERA_DIR}:${PATH}"
fi

# Conda ========================================================================
if [[ -d "$CONDA_DIR" ]]; then
    source "${CONDA_DIR}/activate"
fi

# bcbio ========================================================================
if [[ -d "$BCBIO_DIR" ]]; then
    if [[ ! -f "${BCBIO_DIR}/bcbio_nextgen.py" ]]; then
        echo "bcbio_nextgen.py missing"
        return 1
    fi
    export PATH="${BCBIO_DIR}:${PATH}"
    unset -v PYTHONHOME PYTHONPATH
fi
