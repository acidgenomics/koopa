#!/usr/bin/env bash

# NOTE Consider adding support for help2man during build.

main() {
    # """
    # Install flex.
    # @note Updated 2023-04-10.
    #
    # @seealso
    # - https://github.com/westes/flex/
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/flex.rb
    # """
    local -A dict
    local -a conf_args
    koopa_activate_app --build-only 'bison'
    koopa_activate_app 'gettext' 'm4'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    conf_args=(
        '--disable-dependency-tracking'
        '--disable-silent-rules'
        '--disable-static'
        '--enable-shared'
        "--prefix=${dict['prefix']}"
    )
    dict['url']="https://github.com/westes/flex/releases/download/\
v${dict['version']}/flex-${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_make_build "${conf_args[@]}"
    return 0
}
