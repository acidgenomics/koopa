#!/usr/bin/env bash

main() {
    # """
    # Install chezmoi.
    # @note Updated 2023-12-22.
    #
    # @seealso
    # - https://www.chezmoi.io/
    # - https://github.com/twpayne/chezmoi
    # - https://formulae.brew.sh/formula/chezmoi
    # - https://ports.macports.org/port/chezmoi/details/
    # """
    local -A dict
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['ldflags']="-X main.version=${dict['version']}"
    dict['url']="https://github.com/twpayne/chezmoi/archive/refs/tags/\
v${dict['version']}.tar.gz"
    koopa_build_go_package \
        --ldflags="${dict['ldflags']}" \
        --url="${dict['url']}" \
        --version="${dict['version']}"
    return 0
}
