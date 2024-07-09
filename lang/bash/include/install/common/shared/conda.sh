#!/usr/bin/env bash

# FIXME Rework this to not change default channels to conda-forge and bioconda.
# Instead, set this in the 'conda-package' recipes, reworking as 'conda-forge'
# and 'bioconda' packages instead.

main() {
    # """
    # Install Miniconda.
    # @note Updated 2024-03-12.
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
    dict['koopa_prefix']="$(koopa_koopa_prefix)"
    dict['os_type']="$(koopa_os_type)"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['py_version']='3.12'
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
    dict['url']="https://repo.continuum.io/miniconda/${dict['script']}"
    koopa_download "${dict['url']}" "${dict['script']}"
    "${app['bash']}" "${dict['script']}" -bf -p "${dict['prefix']}"
    koopa_cp \
        "${dict['koopa_prefix']}/etc/conda/condarc" \
        "${dict['prefix']}/.condarc"
    app['conda']="${dict['prefix']}/bin/conda"
    koopa_assert_is_installed "${app['conda']}"
    "${app['conda']}" list
    "${app['conda']}" info --all
    "${app['conda']}" config --show
    return 0
}
