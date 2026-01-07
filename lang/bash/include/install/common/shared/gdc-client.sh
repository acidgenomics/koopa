#!/usr/bin/env bash

install_from_conda() {
    koopa_install_conda_package
    return 0
}

install_from_conda_python312() {
    # """
    # Install GDC client pinned against Python 3.12 for Zscaler compatibility.
    # @updated 2026-01-07.
    #
    # @seealso
    # - https://github.com/NCI-GDC/gdc-client
    #- https://github.com/bioconda/bioconda-recipes/blob/master/recipes/
    #  gdc-client/meta.yaml
    # """
    local -A dict
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['libexec']="${dict['prefix']}/libexec"
    set -x
    koopa_mkdir "${dict['libexec']}"
    koopa_conda_create_env --prefix="${dict['libexec']}" \
        --channel='conda-forge' \
        python==3.12
    koopa_conda_activate_env "${dict['libexec']}"
    conda install \
        --yes \
        --channel='conda-forge' \
        --channel='bioconda' \
        "gdc-client==${dict['version']}"
    koopa_conda_deactivate
    koopa_mkdir "${dict['prefix']}/bin"
    koopa_cd "${dict['prefix']}/bin"
    koopa_ln '../libexec/bin/gdc-client' 'gdc-client'
    return 0

}

main() {
    if koopa_has_ssl_cert_file
    then
        install_from_conda_python312
    else
        install_from_conda
    fi
    return 0
}
