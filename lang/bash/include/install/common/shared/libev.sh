#!/usr/bin/env bash

main() {
    # """
    # Install libev.
    # @note Updated 2025-02-20.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/libev.rb
    # """
    local -A dict
    local -a conf_args
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    conf_args=(
        '--disable-dependency-tracking'
        '--disable-static'
        "--prefix=${dict['prefix']}"
    )
# >     dict['url']="http://dist.schmorp.de/libev/Attic/\
# > libev-${dict['version']}.tar.gz"
    dict['url']="https://fossies.org/linux/misc/libev-${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_make_build "${conf_args[@]}"
    return 0
}
