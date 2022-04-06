#!/usr/bin/env bash

install_fish() { # {{{1
    # """
    # Install Fish shell.
    # @note Updated 2022-04-06.
    # @seealso
    # - https://github.com/fish-shell/fish-shell/#building
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [cmake]="$(koopa_locate_cmake)"
    )
    declare -A dict=(
        [bin_prefix]="$(koopa_bin_prefix)"
        [jobs]="$(koopa_cpu_count)"
        [link_in_bin]="${INSTALL_LINK_IN_BIN:?}"
        [name]='fish'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    if koopa_is_macos
    then
        koopa_activate_homebrew_opt_prefix \
            'ncurses' \
            'pcre2'
    fi
    dict[file]="${dict[name]}-${dict[version]}.tar.xz"
    dict[url]="https://github.com/${dict[name]}-shell/${dict[name]}-shell/\
releases/download/${dict[version]}/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name]}-${dict[version]}"
    "${app[cmake]}" \
        -S '.' \
        -B 'build' \
        -DCMAKE_INSTALL_PREFIX="${dict[prefix]}"
    "${app[cmake]}" \
        --build 'build' \
        --parallel "${dict[jobs]}"
    "${app[cmake]}" --install 'build'
    if [[ "${dict[link_in_bin]}" -eq 1 ]]
    then
        koopa_enable_shell_for_all_users "${dict[bin_prefix]}/${dict[name]}"
    fi
    return 0
}
