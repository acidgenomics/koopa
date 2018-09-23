# Export PATH string.

# General ======================================================================
# Export local user binaries.
# ~/.local/bin
if [[ -d "${HOME}/.local/bin" ]]; then
    export PATH="${PATH}:${HOME}/.local/bin"
fi
# ~/bin
if [[ -d "${HOME}/bin" ]]; then
    export PATH="${PATH}:${HOME}/bin"
fi

# koopa ========================================================================
# Export general koopa scripts.
export PATH="${KOOPA_BINDIR}:${PATH}"

# Export HPC scheduler scripts.
if [[ -n "$HPC_SCHEDULER" ]]; then
    export PATH="${KOOPA_BINDIR}/hpc:${PATH}"
fi

# Export additional OS-specific scripts.
if [[ "$KOOPA_SYSTEM" =~ "Darwin"* ]]; then
    # macOS
    export PATH="${KOOPA_BINDIR}/darwin:${PATH}"
elif [[ "$KOOPA_SYSTEM" =~ "Ubuntu"* ]]; then
    # Ubuntu
    export PATH="${KOOPA_BINDIR}/ubuntu:${PATH}"
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
        echo "bcbio_nextgen.py missing in ${BCBIO_DIR}"
        exit 1
    fi
    export PATH="${BCBIO_DIR}:${PATH}"
    unset -v PYTHONHOME PYTHONPATH
fi
