#!/usr/bin/env bash

# Don't use 5.6 release series, which has an SSH exploit backdoor:
# - https://tukaani.org/xz-backdoor/
# - https://github.com/orgs/Homebrew/discussions/5243

main() {
    # """
    # Install xz.
    # @note Updated 2024-04-01.

    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/xz.rb
    # """
    local -A dict
    local -a conf_args
    koopa_activate_app --build-only 'pkg-config'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    conf_args=(
        '--disable-debug'
        '--disable-dependency-tracking'
        '--disable-silent-rules'
        '--disable-static'
        "--prefix=${dict['prefix']}"
    )
    dict['url']="https://downloads.sourceforge.net/project/lzmautils/\
xz-${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_make_build "${conf_args[@]}"
    return 0
}
