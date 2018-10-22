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
export PATH="${KOOPA_BIN_DIR}:${PATH}"

# Export HPC scheduler scripts.
if [[ -n "$HPC_SCHEDULER" ]]; then
    export PATH="${KOOPA_BIN_DIR}/hpc:${PATH}"
fi

# Export additional OS-specific scripts.
if [[ "$KOOPA_SYSTEM" =~ "Darwin"* ]]; then
    # macOS
    export PATH="${KOOPA_BIN_DIR}/darwin:${PATH}"
elif [[ "$KOOPA_SYSTEM" =~ "Ubuntu"* ]]; then
    # Ubuntu
    export PATH="${KOOPA_BIN_DIR}/ubuntu:${PATH}"
fi

# Aspera Connect ===============================================================
if [[ -z "$ASPERACONNECT_EXE" ]]; then
    aspera_exe="${HOME}/.aspera/connect/bin/asperaconnect"
    if [[ -f "$aspera_exe" ]]; then
        export ASPERACONNECT_EXE="$aspera_exe"
        unset -v aspera_exe
    fi
fi
if [[ -f "$ASPERACONNECT_EXE" ]]; then
    aspera_bin_dir="$( dirname "$ASPERACONNECT_EXE" )"
    export PATH="${aspera_bin_dir}:${PATH}"
    unset -v aspera_bin_dir
fi

# Conda ========================================================================
if [[ -f "$CONDA_EXE" ]]; then
    conda_bin_dir="$( dirname "$CONDA_EXE" )"
    source "${conda_bin_dir}/activate"
    unset -v conda_bin_dir
fi

# bcbio ========================================================================
if [[ -f "$BCBIO_EXE" ]]; then
    bcbio_bin_dir="$( dirname "$BCBIO_EXE" )"
    export PATH="${bcbio_bin_dir}:${PATH}"
    unset -v PYTHONHOME PYTHONPATH
    unset -v bcbio_bin_dir
fi
