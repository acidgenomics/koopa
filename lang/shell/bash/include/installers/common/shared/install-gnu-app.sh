#!/usr/bin/env bash

main() { # {{{1
    # """
    # Build and install a GNU package from source.
    # @note Updated 2022-04-19.
    #
    # Positional arguments are passed to 'conf_args' array.
    # """
    local app conf_args dict
    koopa_activate_opt_prefix 'pkg-config'
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
    dict[name2]="${dict[name]}"
    conf_args=("--prefix=${dict[prefix]}" "$@")
    case "${dict[name]}" in
        'freetype')
            dict[gnu_mirror]='https://download.savannah.gnu.org/releases'
            ;;
    esac
    case "${dict[name]}" in
        'bc' | \
        'groff' | \
        'gsl' | \
        'less' | \
        'libidn' | \
        'libtasn1' | \
        'libunistring' | \
        'make' | \
        'ncurses' | \
        'nettle' | \
        'patch' | \
        'stow' | \
        'tar' | \
        'wget' | \
        'which')
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
        'libidn')
            dict[name2]='libidn2'
            ;;
        'ncurses')
            dict[version]="$(koopa_major_minor_version "${dict[version]}")"
            ;;
    esac
    dict[file]="${dict[name2]}-${dict[version]}.tar.${dict[suffix]}"
    dict[url]="${dict[gnu_mirror]}/${dict[name]}/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name2]}-${dict[version]}"
    # > koopa_dl 'configure args' "${conf_args[*]}"
    ./configure "${conf_args[@]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    # > "${app[make]}" check || true
    "${app[make]}" install
    return 0
}
