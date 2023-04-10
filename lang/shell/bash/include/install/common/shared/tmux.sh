#!/usr/bin/env bash

main() {
    # """
    # Install Tmux.
    # @note Updated 2023-04-06.
    #
    # Consider adding tmux to enabled login shells in a future update.
    # """
    local -A app dict 
    local -a conf_args
    koopa_activate_app --build-only 'make' 'pkg-config'
    koopa_activate_app \
        'libevent' \
        'ncurses' \
        'utf8proc'
    app['make']="$(koopa_locate_make)"
    koopa_assert_is_executable "${app[@]}"
    dict['jobs']="$(koopa_cpu_count)"
    dict['name']='tmux'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['file']="${dict['name']}-${dict['version']}.tar.gz"
    dict['url']="https://github.com/${dict['name']}/${dict['name']}/releases/\
download/${dict['version']}/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    conf_args=(
        "--prefix=${dict['prefix']}"
        '--enable-utf8proc'
    )
    koopa_print_env
    koopa_dl 'configure args' "${conf_args[*]}"
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    "${app['make']}" install
    return 0
}
