#!/usr/bin/env bash

# FIXME Rework using dict approach.
koopa:::linux_install_cellranger() { # {{{1
    # """
    # Install Cell Ranger.
    # @note Updated 2021-11-16.
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
