#!/usr/bin/env bash

koopa:::install_anaconda() { # {{{1
    # """
    # Install full Anaconda distribution.
    # @note Updated 2021-11-18.
    # """
    local app dict
    koopa::assert_has_no_args "$#"
    declare -A app=(
        [bash]="$(koopa::locate_bash)"
    )
    declare -A dict=(
        [arch]="$(koopa::arch)"
        [koopa_prefix]="$(koopa::koopa_prefix)"
        [os_type]="$(koopa::os_type)"
        [prefix]="${INSTALL_PREFIX:?}"
        [py_maj_ver]='3'
        [version]="${INSTALL_VERSION:?}"
    )
    case "${dict[os_type]}" in
        'darwin'*)
            dict[os_type]='MacOSX'
            ;;
        'linux'*)
            dict[os_type]='Linux'
            ;;
        *)
            koopa::stop "'${dict[os_type]}' is not supported."
            ;;
    esac
    dict[file]="Anaconda${dict[py_maj_ver]}-${dict[version]}-\
${dict[os_type]}-${dict[arch]}.sh"
    dict[url]="https://repo.anaconda.com/archive/${dict[file]}"
    koopa::download "${dict[url]}" "${dict[file]}"
    "${app[bash]}" "${dict[file]}" -bf -p "${dict[prefix]}"
    koopa::ln \
        "${dict[koopa_prefix]}/etc/conda/condarc" \
        "${dict[prefix]}/.condarc"
    return 0
}
