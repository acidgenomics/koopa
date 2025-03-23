#!/usr/bin/env bash

main() {
    # """
    # Install Quarto.
    # @note Updated 2023-06-01.
    #
    # @seealso
    # - https://quarto.org/docs/download/
    # - https://github.com/quarto-dev/quarto-cli/
    # """
    local -A dict
    dict['arch']="$(koopa_arch2)" # e.g. "amd64".
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    if koopa_is_linux
    then
        dict['slug']="linux-${dict['arch']}"
    elif koopa_is_macos
    then
        dict['slug']='macos'
    fi
    dict['url']="https://github.com/quarto-dev/quarto-cli/releases/download/\
v${dict['version']}/quarto-${dict['version']}-${dict['slug']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract \
        "$(koopa_basename "${dict['url']}")" \
        "${dict['prefix']}"
    return 0
}
