#!/usr/bin/env bash

main() {
    # """
    # Install Tmux.
    # @note Updated 2023-04-11.
    #
    # Consider adding tmux to enabled login shells in a future update.
    # """
    local -A dict
    local -a build_deps conf_args deps
    build_deps+=('bison' 'pkg-config')
    deps+=('libevent' 'ncurses' 'utf8proc')
    koopa_activate_app --build-only "${build_deps[@]}"
    koopa_activate_app "${deps[@]}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    conf_args=(
        '--enable-utf8proc'
        "--prefix=${dict['prefix']}"
    )
    dict['url']="https://github.com/tmux/tmux/releases/download/\
${dict['version']}/tmux-${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_make_build "${conf_args[@]}"
    return 0
}
