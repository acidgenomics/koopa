#!/usr/bin/env bash

install_gnu_app() { # {{{1
    # """
    # Build and install a GNU package from source.
    # @note Updated 2022-03-29.
    #
    # Positional arguments are passed to 'conf_args' array.
    # """
    local app conf_args dict
    declare -A app=(
        [make]="$(koopa_locate_make)"
    )
    declare -A dict=(
        [gnu_mirror]="$(koopa_gnu_mirror_url)"
        [jobs]="$(koopa_cpu_count)"
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
    case "${dict[name]}" in
        'ncurses')
            dict[version]="$(koopa_major_minor_version "${dict[version]}")"
            ;;
    esac
    dict[file]="${dict[name]}-${dict[version]}.tar.${dict[suffix]}"
    dict[url]="${dict[gnu_mirror]}/${dict[name]}/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name]}-${dict[version]}"
    ./configure "${conf_args[@]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    # > "${app[make]}" check
    "${app[make]}" install
    return 0
}
