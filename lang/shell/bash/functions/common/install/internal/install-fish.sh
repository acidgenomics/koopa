#!/usr/bin/env bash

koopa:::install_fish() { # {{{1
    # """
    # Install Fish shell.
    # @note Updated 2021-11-23.
    # @seealso
    # - https://github.com/fish-shell/fish-shell/#building
    # """
    local app dict
    declare -A app=(
        [cmake]="$(koopa::locate_cmake)"
    )
    declare -A dict=(
        [jobs]="$(koopa::cpu_count)"
        [link_app]="${INSTALL_LINK_APP:?}"
        [name]='fish'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    if koopa::is_macos
    then
        koopa::activate_homebrew_opt_prefix \
            'ncurses' \
            'pcre2'
    fi
    dict[file]="${dict[name]}-${dict[version]}.tar.xz"
    dict[url]="https://github.com/${dict[name]}-shell/${dict[name]}-shell/\
releases/download/${dict[version]}/${dict[file]}"
    koopa::download "${dict[url]}" "${dict[file]}"
    koopa::extract "${dict[file]}"
    koopa::cd "${dict[name]}-${dict[version]}"
    "${app[cmake]}" \
        -S '.' \
        -B 'build' \
        -DCMAKE_INSTALL_PREFIX="${dict[prefix]}"
    "${app[cmake]}" \
        --build 'build' \
        --parallel "${dict[jobs]}"
    "${app[cmake]}" --install 'build'
    if [[ "${dict[link_app]}" -eq 1 ]]
    then
        koopa::enable_shell "${dict[name]}"
    fi
    return 0
}
