#!/usr/bin/env bash

# Activate koopa in the current shell.

# Check for supported operating system.
# Alternatively can use `$(uname -s)`
# solaris, bsd are not supported.
case "$OSTYPE" in
    darwin* ) os="macOS";;
     linux* ) os="Linux";;
          * ) echo "Unsupported system: ${OSTYPE}"; exit 1;;
esac

# Current date (e.g. 2018-01-01).
export TODAY=$(date +%Y-%m-%d)

# R environmental variables.
export R_DEFAULT_PACKAGES="stats,graphics,grDevices,utils,datasets,methods,base"

# Genome build versions.
export ENSEMBL_RELEASE="94"
export ENSEMBL_RELEASE_URL="ftp://ftp.ensembl.org/pub/release-${ENSEMBL_RELEASE}"
export GENCODE_RELEASE="29"
export FLYBASE_RELEASE_DATE="FB2018_05"
export FLYBASE_RELEASE_VERSION="r6.24"
export FLYBASE_RELEASE_URL="ftp://ftp.flybase.net/releases/${FLYBASE_RELEASE_DATE}/dmel_${FLYBASE_RELEASE_VERSION}"
export WORMBASE_RELEASE_VERSION="WS266"

# Stack Overflow on PATH expansion matching.
# https://stackoverflow.com/questions/1396066

# Export user binaries, if necessary.
dir="${HOME}/.local/bin"
if [[ -d "$dir" ]] && [[ ":$PATH:" == *":${dir}:"* ]]; then
    export PATH="${PATH}:${dir}"
fi
dir="${HOME}/.local/bin"
if [[ -d "$dir" ]] && [[ ":$PATH:" == *":${dir}:"* ]]; then
    export PATH="${PATH}:${dir}"
fi
unset -v dir

# Platform-agnostic binaries.
export PATH="${KOOPA_BIN_DIR}:${PATH}"

# Export additional OS-specific scripts.
if [[ "$KOOPA_SYSTEM" =~ "Darwin"* ]]; then
    # macOS
    export PATH="${KOOPA_BIN_DIR}/darwin:${PATH}"
elif [[ "$KOOPA_SYSTEM" =~ "Ubuntu"* ]]; then
    # Ubuntu
    export PATH="${KOOPA_BIN_DIR}/ubuntu:${PATH}"
fi

# Aspera Connect
if [[ -z ${ASPERACONNECT_EXE+x} ]]; then
    aspera_exe="${HOME}/.aspera/connect/bin/asperaconnect"
    if [[ -f "$aspera_exe" ]]; then
        export ASPERACONNECT_EXE="$aspera_exe"
        unset -v aspera_exe
    else
        ASPERACONNECT_EXE=0
    fi
fi
if [[ -f "ASPERACONNECT_EXE" ]]; then
    aspera_bin_dir="$( dirname "$ASPERACONNECT_EXE" )"
    export PATH="${aspera_bin_dir}:${PATH}"
    unset -v aspera_bin_dir
fi

# Conda
if [[ -n ${CONDA_EXE+x} ]]; then
    # Check that path is valid.
    if [[ ! -f "$CONDA_EXE" ]]; then
        printf "conda does not exist at:\n${CONDA_EXE}\n"
    fi
    conda_bin_dir="$( dirname "$CONDA_EXE" )"
    source "${conda_bin_dir}/activate"
    unset -v conda_bin_dir
fi

# bcbio
if [[ -n ${BCBIO_EXE+x} ]]; then
    # Check that path is valid.
    if [[ ! -f "$BCBIO_EXE" ]]; then
        printf "bcbio does not exist at:\n${BCBIO_EXE}\n"
    fi
    bcbio_bin_dir="$( dirname "$BCBIO_EXE" )"
    export PATH="${bcbio_bin_dir}:${PATH}"
    unset -v PYTHONHOME PYTHONPATH
    unset -v bcbio_bin_dir
fi
