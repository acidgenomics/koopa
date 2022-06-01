#!/usr/bin/env bash

main() {
    # """
    # Install Tmux.
    # @note Updated 2022-06-01.
    #
    # Consider adding tmux to enabled login shells in a future update.
    # """
    local app conf_args dict
    koopa_assert_has_no_args "$#"
    koopa_activate_build_opt_prefix 'pkg-config'
    koopa_activate_opt_prefix \
        'libevent' \
        'ncurses' \
        'utf8proc'
    declare -A app=(
        [make]="$(koopa_locate_make)"
    )
    declare -A dict=(
        [jobs]="$(koopa_cpu_count)"
        [name]='tmux'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[file]="${dict[name]}-${dict[version]}.tar.gz"
    dict[url]="https://github.com/${dict[name]}/${dict[name]}/releases/\
download/${dict[version]}/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name]}-${dict[version]}"
    conf_args=(
        "--prefix=${dict[prefix]}"
        '--enable-utf8proc'
    )
    ./configure "${conf_args[@]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    "${app[make]}" install
    app[tmux]="${dict[prefix]}/bin/tmux"
    koopa_assert_is_installed "${app[tmux]}"
    "${app[tmux]}" kill-server &>/dev/null || true
    return 0
}
