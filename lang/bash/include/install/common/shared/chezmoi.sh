#!/usr/bin/env bash

main() {
    # """
    # Install chezmoi.
    # @note Updated 2023-08-28.
    #
    # @seealso
    # - https://www.chezmoi.io/
    # - https://github.com/twpayne/chezmoi
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/chezmoi.rb
    # - https://ports.macports.org/port/chezmoi/details/
    # """
    local -A dict
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="https://github.com/twpayne/chezmoi/archive/refs/tags/\
v${dict['version']}.tar.gz"
    koopa_install_app_subshell \
        --installer='go-package' \
        --name='chezmoi' \
        -D "--ldflags=-X main.version=${dict['version']}" \
        -D "--url=${dict['url']}"
    return 0
}
