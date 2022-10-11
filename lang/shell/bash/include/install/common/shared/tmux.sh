#!/usr/bin/env bash

main() {
    # """
    # Install Tmux.
    # @note Updated 2022-08-16.
    #
    # Consider adding tmux to enabled login shells in a future update.
    # """
    local app conf_args dict
    koopa_assert_has_no_args "$#"
    koopa_activate_app --build-only 'pkg-config'
    koopa_activate_app \
        'libevent' \
        'ncurses' \
        'utf8proc'
    declare -A app=(
        ['make']="$(koopa_locate_make)"
    )
    [[ -x "${app['make']}" ]] || return 1
    declare -A dict=(
        ['jobs']="$(koopa_cpu_count)"
        ['name']='tmux'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
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
    # This can kill system tmux server, so keep disabled.
    # > app['tmux']="${dict['prefix']}/bin/tmux"
    # > koopa_assert_is_installed "${app['tmux']}"
    # > "${app['tmux']}" kill-server &>/dev/null || true
    return 0
}
