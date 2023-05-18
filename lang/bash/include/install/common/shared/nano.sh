#!/usr/bin/env bash

# NOTE Consider requiring 'libmagic' on Linux.

main() {
    # """
    # Install nano.
    # @note Updated 2023-04-10.
    #
    # @seealso
    # - https://www.nano-editor.org/
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/nano.rb
    # """
    local -A dict
    local -a conf_args
    koopa_activate_app --build-only 'pkg-config'
    koopa_activate_app 'gettext' 'ncurses'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['maj_ver']="$(koopa_major_version "${dict['version']}")"
    conf_args=(
        '--disable-debug'
        '--disable-dependency-tracking'
        '--enable-color'
        '--enable-extra'
        '--enable-multibuffer'
        '--enable-nanorc'
        '--enable-utf8'
        "--prefix=${dict['prefix']}"
    )
    dict['url']="https://www.nano-editor.org/dist/v${dict['maj_ver']}/\
nano-${dict['version']}.tar.xz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_make_build "${conf_args[@]}"
    return 0
}
