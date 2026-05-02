#!/usr/bin/env bash

main() {
    # """
    # Install Elvish.
    # @note Updated 2026-05-01.
    #
    # @seealso
    # - https://elv.sh/
    # - https://github.com/elves/elvish/
    # - https://github.com/elves/elvish/blob/master/GNUmakefile
    # """
    local -A dict
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="https://github.com/elves/elvish/archive/refs/tags/\
v${dict['version']}.tar.gz"
    _koopa_build_go_package \
        --url="${dict['url']}"
    return 0
}
