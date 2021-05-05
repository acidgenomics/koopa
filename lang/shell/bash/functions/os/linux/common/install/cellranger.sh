#!/usr/bin/env bash

koopa::linux_install_cellranger() { # {{{1
    koopa::linux_install_app \
        --name='cellranger' \
        --name-fancy='CellRanger' \
        --no-link \
        "$@"
}

koopa:::linux_install_cellranger() { # {{{1
    # """
    # Install Cell Ranger.
    # @note Updated 2021-05-05.
    #
    # Refdata is accessible here:
    # https://support.10xgenomics.com/single-cell-gene-expression/
    #     software/downloads/latest
    # """
    local file name prefix url version
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    name='cellranger'
    file="${name}-${version}.tar.gz"
    url="https://seq.cloud/install/cellranger/${file}"
    koopa::download "$url"
    koopa::extract "$file"
    koopa::sys_mv "${name}-${version}" "$prefix"
    return 0
}
