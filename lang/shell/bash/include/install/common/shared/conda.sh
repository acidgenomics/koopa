#!/usr/bin/env bash

main() {
    # """
    # Install Miniconda.
    # @note Updated 2023-01-03.
    #
    # @seealso
    # - https://www.anaconda.com/blog/conda-is-fast-now
    # - https://www.anaconda.com/blog/a-faster-conda-for-a-growing-community
    # - https://github.com/conda/conda-libmamba-solver
    # - https://github.com/mamba-org/mamba
    # """
    local app dict
    koopa_assert_is_not_aarch64
    declare -A app
    app['bash']="$(koopa_locate_bash --allow-system)"
    [[ -x "${app['bash']}" ]] || return 1
    declare -A dict=(
        ['arch']="$(koopa_arch)" # e.g. 'x86_64'.
        ['from_latest']=0
        ['koopa_prefix']="$(koopa_koopa_prefix)"
        ['os_type']="$(koopa_os_type)"
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['py_version']="3.10"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
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
    case "${dict['version']}" in
        '22.11.1')
            dict['version2']="${dict['version']}-1"
            ;;
        *)
            dict['version2']="${dict['version']}"
            ;;
    esac
    dict['script']="Miniconda${dict['py_major_version']}-\
py${dict['py_version2']}_${dict['version2']}-${dict['os_type2']}\
-${dict['arch2']}.sh"
# >     # NOTE Temporary workaround for installing newer versions that aren't
# >     # yet available at 'https://repo.anaconda.com/miniconda/'.
# >     case "${dict['version']}" in
# >         '22.11.1')
# >             dict['from_latest']=1
# >             dict['script']="Miniconda${dict['py_major_version']}-latest-\
# > ${dict['os_type2']}-${dict['arch2']}.sh"
# >             dict['libmamba_version']='22.12.0'
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
        # NOTE Can add '--solver=classic' from 22.11.* onwards here.
        "${app['conda']}" install \
            --channel='conda-forge' \
            --name='base' \
            --override-channels \
            --yes \
            "conda==${dict['version']}" \
            "conda-libmamba-solver==${dict['libmamba_version']}"
    fi
    "${app['conda']}" list
    "${app['conda']}" info --all
    "${app['conda']}" config --show
    return 0
}
