#!/usr/bin/env bash

main() {
    # """
    # Install STAR from bioconda.
    # @note Updated 2023-10-17.
    # """
    local -A dict
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    koopa_install_conda_package
    # FIXME Need to patch SCRIPT_DIR path for STAR and STARlong on Linux.
    return 0
}
