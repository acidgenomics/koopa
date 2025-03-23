#!/usr/bin/env bash

main() {
    # """
    # Install direnv.
    # @note Updated 2025-01-30.
    #
    # @seealso
    # - https://github.com/direnv/direnv/
    # - https://formulae.brew.sh/formula/direnv
    # - https://github.com/conda-forge/direnv-feedstock
    # """
    local -A dict
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="https://github.com/direnv/direnv/archive/refs/tags/\
v${dict['version']}.tar.gz"
    koopa_build_go_package \
        --url="${dict['url']}"
    return 0
}
