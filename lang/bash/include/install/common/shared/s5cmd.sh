#!/usr/bin/env bash

main() {
    # """
    # Install s5cmd.
    # @note Updated 2024-08-01.
    #
    # Build support for 's5cmd version' isn't great at the moment:
    # https://github.com/peak/s5cmd/blob/master/Makefile
    #
    # @seealso
    # - https://github.com/peak/homebrew-tap/
    # - https://ports.macports.org/port/s5cmd/
    # """
    local -A dict
    local -a ldflags
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="https://github.com/peak/s5cmd/archive/refs/tags/\
v${dict['version']}.tar.gz"
    ldflags+=('-s' '-w')
    ldflags+=("-X=github.com/peak/s5cmd/v2/version.Version=${dict['version']}")
    dict['ldflags']="${ldflags[*]}"
    koopa_build_go_package \
        --ldflags="${dict['ldflags']}" \
        --url="${dict['url']}"
    return 0
}
