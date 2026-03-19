#!/usr/bin/env bash

main() {
    # """
    # Install Databricks CLI.
    # @note Updated 2026-03-19.
    #
    # @seealso
    # - https://github.com/conda-forge/databricks-cli-feedstock/
    # """
    local -A dict
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="https://github.com/databricks/cli/archive/\
v${dict['version']}.tar.gz"
    koopa_build_go_package \
        --bin-name='databricks' \
        --prefix="${dict['prefix']}" \
        --url="${dict['url']}" \
        --version="${dict['version']}"
    return 0
}
