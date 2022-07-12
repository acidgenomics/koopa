#!/usr/bin/env bash

main() {
    # """
    # Install Fish shell.
    # @note Updated 2022-07-12.
    #
    # @seealso
    # - https://github.com/fish-shell/fish-shell/#building
    # """
    local app cmake_args dict
    koopa_assert_has_no_args "$#"
    koopa_activate_build_opt_prefix 'cmake'
    koopa_activate_opt_prefix 'ncurses' 'pcre2'
    declare -A app=(
        [cmake]="$(koopa_locate_cmake)"
    )
    declare -A dict=(
        [bin_prefix]="$(koopa_bin_prefix)"
        [jobs]="$(koopa_cpu_count)"
        [link_in_bin]="${INSTALL_LINK_IN_BIN:?}"
        [name]='fish'
        [opt_prefix]="$(koopa_opt_prefix)"
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[ncurses]="$(koopa_realpath "${dict[opt_prefix]}/ncurses")"
    dict[file]="${dict[name]}-${dict[version]}.tar.xz"
    dict[url]="https://github.com/${dict[name]}-shell/${dict[name]}-shell/\
releases/download/${dict[version]}/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name]}-${dict[version]}"
    cmake_args=(
        "-DCMAKE_INSTALL_PREFIX=${dict[prefix]}"
        "-DCURSES_INCLUDE_PATH=${dict[ncurses]}/include"
    )
    "${app[cmake]}" \
        -S '.' \
        -B 'build' \
        "${cmake_args[@]}"
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
