#!/usr/bin/env bash

# FIXME Need to move this function somewhere else in package.
koopa:::install_gnu_app() { # {{{1
    # """
    # Build and install a GNU package from source.
    # @note Updated 2021-11-13.
    #
    # Positional arguments are passed to 'conf_args' array.
    # """
    local app conf_args dict
    declare -A app=(
        [make]="$(koopa::locate_make)"
    )
    declare -A dict=(
        [gnu_mirror]="$(koopa::gnu_mirror_url)"
        [jobs]="$(koopa::cpu_count)"
        [name]="${INSTALL_NAME:?}"
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    conf_args=("--prefix=${dict[prefix]}" "$@")
    case "${dict[name]}" in
        'groff' | \
        'gsl' | \
        'make' | \
        'ncurses' | \
        'patch' | \
        'tar' | \
        'wget')
            dict[suffix]='gz'
            ;;
        'parallel')
            dict[suffix]='bz2'
            ;;
        *)
            dict[suffix]='xz'
            ;;
    esac
    dict[file]="${dict[name]}-${dict[version]}.tar.${dict[suffix]}"
    dict[url]="${dict[gnu_mirror]}/${dict[name]}/${dict[file]}"
    koopa::download "${dict[url]}" "${dict[file]}"
    koopa::extract "${dict[file]}"
    koopa::cd "${dict[name]}-${dict[version]}"
    ./configure "${conf_args[@]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    # > "${app[make]}" check
    "${app[make]}" install
    return 0
}
