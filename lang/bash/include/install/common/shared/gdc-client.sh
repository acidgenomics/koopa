#!/usr/bin/env bash

install_from_conda() {
    koopa_install_conda_package
    return 0
}

install_from_source() {
    # """
    # Install GDC client pinned against Python 3.12 for Zscaler compatibility.
    # @updated 2026-01-07.
    #
    # @seealso
    # - https://github.com/NCI-GDC/gdc-client
    #- https://github.com/bioconda/bioconda-recipes/blob/master/recipes/
    #  gdc-client/meta.yaml
    # """
    local -A app dict
    app['python']="$(koopa_locate_python312)"
    koopa_assert_is_executable "${app[@]}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['libexec']="${dict['prefix']}/libexec"
    dict['url']="https://github.com/NCI-GDC/gdc-client/archive/refs/\
tags/${dict['version']}.tar.gz"
    koopa_download "${dict['url']}" 'src.tar.gz'
    koopa_extract 'src.tar.gz' 'src'
    koopa_cd 'src'
    koopa_python_create_venv \
        --prefix="${dict['libexec']}" \
        --python="${app['python']}"
    app['venv_python']="${dict['libexec']}/bin/python3"
    koopa_assert_is_executable "${app['venv_python']}"
    export SETUPTOOLS_SCM_PRETEND_VERSION="${dict['version']}"
    "${app['venv_python']}" -m pip install \
        --no-cache-dir -r requirements.txt
    "${app['venv_python']}" -m pip install \
        --no-cache-dir --no-deps --use-pep517 .
    koopa_mkdir "${dict['prefix']}/bin"
    koopa_cd "${dict['prefix']}/bin"
    koopa_ln '../libexec/bin/gdc-client' 'gdc-client'
    return 0

}

main() {
    if koopa_has_ssl_cert_file
    then
        install_from_source
    else
        install_from_conda
    fi
    return 0
}
