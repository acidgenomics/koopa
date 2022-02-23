#!/usr/bin/env bash

koopa:::install_conda() { # {{{1
    # """
    # Install Miniconda.
    # @note Updated 2022-02-23.
    #
    # Optionally, can include Mamba in base environment using '--with-mamba'.
    # """
    local app dict
    declare -A app=(
        [bash]="$(koopa::locate_bash)"
    )
    declare -A dict=(
        [arch]="$(koopa::arch)"
        [koopa_prefix]="$(koopa::koopa_prefix)"
        [mamba]=0
        [os_type]="$(koopa::os_type)"
        [prefix]="${INSTALL_PREFIX:?}"
        [py_version]="$(koopa::variable 'python')"
        [version]="${INSTALL_VERSION:?}"
    )
    case "${dict[os_type]}" in
        'darwin'*)
            dict[os_type2]='MacOSX'
            ;;
        'linux'*)
            dict[os_type2]='Linux'
            ;;
        *)
            koopa::stop "'${dict[os_type]}' is not supported."
            ;;
    esac
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--py-version='*)
                dict[py_version]="${1#*=}"
                shift 1
                ;;
            '--py-version')
                dict[py_version]="${2:?}"
                shift 1
                ;;
            # Flags ------------------------------------------------------------
            '--no-mamba')
                dict[mamba]=0
                shift 1
                ;;
            '--with-mamba')
                dict[mamba]=1
                shift 1
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    dict[py_version]="$(koopa::major_minor_version "${dict[py_version]}")"
    case "${dict[py_version]}" in
        '3.7' | \
        '3.8' | \
        '3.9')
            ;;
        *)
            dict[py_version]='3.9'
            ;;
    esac
    dict[py_major_version]="$(koopa::major_version "${dict[py_version]}")"
    dict[py_version2]="$( \
        koopa::gsub \
            --pattern='\.' \
            --replacement='' \
            "$(koopa::major_minor_version "${dict[py_version]}")" \
    )"
    dict[script]="Miniconda${dict[py_major_version]}-\
py${dict[py_version2]}_${dict[version]}-${dict[os_type2]}-${dict[arch]}.sh"
    dict[url]="https://repo.continuum.io/miniconda/${dict[script]}"
    koopa::download "${dict[url]}" "${dict[script]}"
    "${app[bash]}" "${dict[script]}" -bf -p "${dict[prefix]}"
    koopa::ln \
        "${dict[koopa_prefix]}/etc/conda/condarc" \
        "${dict[prefix]}/.condarc"
    # Install mamba inside of conda base environment, if desired.
    if [[ "${dict[mamba]}" -eq 1 ]]
    then
        koopa::install_mamba
    fi
    return 0
}
