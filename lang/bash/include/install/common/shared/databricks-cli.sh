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
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="github.com/databricks/cli@v${dict['version']}"
    koopa_install_go_package \
        --bin-name='databricks' \
        --url="${dict['url']}"
    return 0
}
