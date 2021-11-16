#!/usr/bin/env bash

koopa:::install_miniconda() { # {{{1
    # """
    # Install Miniconda, including Mamba in base environment.
    # @note Updated 2021-11-16.
    # """
    local app dict
    declare -A app=(
        [bash]="$(koopa::locate_bash)"
    )
    declare -A dict=(
        [arch]="$(koopa::arch)"
        [koopa_prefix]="$(koopa::koopa_prefix)"
        [mamba]=1
        [mamba_version]="$(koopa::variable 'conda-mamba')"
        [name2]='Miniconda'
        [name]='miniconda'
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
            '\.' '' "$(koopa::major_minor_version "${dict[py_version]}")" \
    )"
    dict[script]="${dict[name2]}${dict[py_major_version]}-\
py${dict[py_version2]}_${dict[version]}-${dict[os_type2]}-${dict[arch]}.sh"
    dict[url]="https://repo.continuum.io/${dict[name]}/${dict[script]}"
    koopa::download "${dict[url]}" "${dict[script]}"
    "${app[bash]}" "${dict[script]}" -bf -p "${dict[prefix]}"
    koopa::ln \
        "${dict[koopa_prefix]}/etc/conda/condarc" \
        "${dict[prefix]}/.condarc"
    # Install mamba inside of conda base environment, if desired.
    if [[ "${dict[mamba]}" -eq 1 ]]
    then
        koopa::alert 'Installing mamba inside conda base environment.'
        app[conda]="${dict[prefix]}/bin/conda"
        koopa::assert_is_installed "${app[conda]}"
        # > koopa::activate_conda "${dict[prefix]}"
        "${app[conda]}" install \
            --yes \
            --name='base' \
            --channel='conda-forge' \
            "mamba==${dict[mamba_version]}"
        # > koopa::deactivate_conda
    fi
    return 0
}
