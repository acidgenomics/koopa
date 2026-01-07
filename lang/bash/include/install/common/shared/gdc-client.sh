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
    dict['conda_env_file']='conda.yaml'
    read -r -d '' "dict[conda_env_string]" << END || true
channels:
  - conda-forge
  - bioconda
dependencies:
  - python =3.12
  - gdc-client =${dict['version']}
END
    koopa_write_string \
        --file="${dict['conda_env_file']}" \
        --string="${dict['conda_env_string']}"
    koopa_install_conda_package --file="${dict['conda_env_file']}"
    koopa_mkdir "${dict['prefix']}/bin"
    (
        koopa_cd "${dict['prefix']}/bin"
        koopa_ln '../libexec/bin/gdc-client' 'gdc-client'
    )
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
