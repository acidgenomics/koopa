#!/usr/bin/env bash

main() {
    # """
    # Install cheat.
    # @note Updated 2023-08-28.
    #
    # @seealso
    # - https://github.com/cheat/cheat/
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/cheat.rb
    # """
    local -A dict
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="https://github.com/cheat/cheat/archive/refs/tags/\
${dict['version']}.tar.gz"
    koopa_install_app_subshell \
        --installer='go-package' \
        --name='cheat' \
        -D '--build-cmd=./cmd/cheat' \
        -D '--mod=vendor' \
        -D "--url=${dict['url']}"
    return 0
}
