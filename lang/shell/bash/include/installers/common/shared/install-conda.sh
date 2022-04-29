#!/usr/bin/env bash

main() { # {{{1
    # """
    # Install Miniconda.
    # @note Updated 2022-04-29.
    # """
    local app dict
    declare -A app=(
        [bash]="$(koopa_locate_bash)"
    )
    declare -A dict=(
        [arch]="$(koopa_arch)" # e.g. 'x86_64'.
        [koopa_prefix]="$(koopa_koopa_prefix)"
        [os_type]="$(koopa_os_type)"
        [prefix]="${INSTALL_PREFIX:?}"
        [py_version]="$(koopa_variable 'python')"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[arch2]="${dict[arch]}"
    case "${dict[os_type]}" in
        'darwin'*)
            dict[os_type2]='MacOSX'
            case "${dict[arch]}" in
                'aarch64')
                    dict[arch2]='arm64'
                    ;;
            esac
            ;;
        'linux'*)
            dict[os_type2]='Linux'
            ;;
        *)
            koopa_stop "'${dict[os_type]}' is not supported."
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
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    dict[py_version]="$(koopa_major_minor_version "${dict[py_version]}")"
    case "${dict[py_version]}" in
        '3.7' | \
        '3.8' | \
        '3.9')
            ;;
        *)
            dict[py_version]='3.9'
            ;;
    esac
    dict[py_major_version]="$(koopa_major_version "${dict[py_version]}")"
    dict[py_version2]="$( \
        koopa_gsub \
            --fixed \
            --pattern='.' \
            --replacement='' \
            "$(koopa_major_minor_version "${dict[py_version]}")" \
    )"
    dict[script]="Miniconda${dict[py_major_version]}-\
py${dict[py_version2]}_${dict[version]}-${dict[os_type2]}-${dict[arch2]}.sh"
    dict[url]="https://repo.continuum.io/miniconda/${dict[script]}"
    koopa_download "${dict[url]}" "${dict[script]}"
    unset -v PYTHONHOME PYTHONPATH
    "${app[bash]}" "${dict[script]}" -bf -p "${dict[prefix]}"
    koopa_ln \
        "${dict[koopa_prefix]}/etc/conda/condarc" \
        "${dict[prefix]}/.condarc"
    return 0
}
