#!/usr/bin/env bash

main() {
    # """
    # Install Miniconda.
    # @note Updated 2023-04-06.
    #
    # @seealso
    # - https://www.anaconda.com/blog/conda-is-fast-now
    # - https://www.anaconda.com/blog/a-faster-conda-for-a-growing-community
    # - https://github.com/conda/conda-libmamba-solver
    # - https://github.com/mamba-org/mamba
    # """
    local -A app dict
    app['bash']="$(koopa_locate_bash --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    dict['arch']="$(koopa_arch)" # e.g. 'x86_64'.
    dict['from_latest']=0
    dict['koopa_prefix']="$(koopa_koopa_prefix)"
    dict['os_type']="$(koopa_os_type)"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['py_version']="3.10"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['arch2']="${dict['arch']}"
    case "${dict['os_type']}" in
        'darwin'*)
            dict['os_type2']='MacOSX'
            case "${dict['arch']}" in
                'aarch64')
                    dict['arch2']='arm64'
                    ;;
            esac
            ;;
        'linux'*)
            dict['os_type2']='Linux'
            ;;
        *)
            koopa_stop "'${dict['os_type']}' is not supported."
            ;;
    esac
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--py-version='*)
                dict['py_version']="${1#*=}"
                shift 1
                ;;
            '--py-version')
                dict['py_version']="${2:?}"
                shift 1
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    dict['py_version']="$(koopa_major_minor_version "${dict['py_version']}")"
    dict['py_major_version']="$(koopa_major_version "${dict['py_version']}")"
    dict['py_version2']="$( \
        koopa_gsub \
            --fixed \
            --pattern='.' \
            --replacement='' \
            "$(koopa_major_minor_version "${dict['py_version']}")" \
    )"
    dict['script']="Miniconda${dict['py_major_version']}-\
py${dict['py_version2']}_${dict['version']}-${dict['os_type2']}\
-${dict['arch2']}.sh"
# >     # Workaround for installing newer versions that aren't yet available
# >     # at 'https://repo.anaconda.com/miniconda/'.
# >     case "${dict['version']}" in
# >         'XXX')
# >             dict['from_latest']=1
# >             dict['script']="Miniconda${dict['py_major_version']}-latest-\
# > ${dict['os_type2']}-${dict['arch2']}.sh"
# >             ;;
# >     esac
    dict['url']="https://repo.continuum.io/miniconda/${dict['script']}"
    koopa_download "${dict['url']}" "${dict['script']}"
    "${app['bash']}" "${dict['script']}" -bf -p "${dict['prefix']}"
    koopa_ln \
        "${dict['koopa_prefix']}/etc/conda/condarc" \
        "${dict['prefix']}/.condarc"
    app['conda']="${dict['prefix']}/bin/conda"
    koopa_assert_is_installed "${app['conda']}"
    if [[ "${dict['from_latest']}" -eq 1 ]]
    then
        "${app['conda']}" install \
            --channel='conda-forge' \
            --name='base' \
            --override-channels \
            --solver='classic' \
            --yes \
            "conda==${dict['version']}"
    fi
    "${app['conda']}" list
    "${app['conda']}" info --all
    "${app['conda']}" config --show
    return 0
}