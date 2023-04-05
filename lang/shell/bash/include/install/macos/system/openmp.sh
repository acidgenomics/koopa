#!/usr/bin/env bash

main() {
    # """
    # Install OpenMP library.
    # @note Updated 2023-02-08.
    #
    # Useful for optimizing performance of 'data.table' package.
    #
    # @seealso
    # - https://mac.r-project.org/openmp/
    # - https://github.com/Rdatatable/data.table/wiki/Installation
    # """
    local app
    declare -A app dict
    koopa_assert_has_no_args "$#"
    app['sudo']="$(koopa_locate_sudo)"
    app['tar']="$(koopa_locate_tar --allow-system)"
    [[ -x "${app['sudo']}" ]] || return 1
    [[ -x "${app['tar']}" ]] || return 1
    dict['name']='openmp'
    dict['platform']='darwin'
    dict['release']='Release' # or 'Debug'.
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    case "${dict['version']}" in
        '13.0.0')
            dict['platform_version']='21'
            ;;
        '14.0.6' | \
        '12.0.1' | \
        '11.0.1')
            dict['platform_version']='20'
            ;;
        '10.0.0' | \
        '9.0.1' | \
        '8.0.1' | \
        '7.1.0')
            dict['platform_version']='17'
            ;;
        *)
            koopa_stop "Unsupported version: '${dict['version']}'."
            ;;
    esac
    dict['file']="${dict['name']}-${dict['version']}-\
${dict['platform']}${dict['platform_version']}-${dict['release']}.tar.gz"
    dict['url']="https://mac.r-project.org/${dict['name']}/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    "${app['sudo']}" "${app['tar']}" -vxz -f "${dict['file']}" -C /
    koopa_assert_is_file \
        '/usr/local/include/omp-tools.h' \
        '/usr/local/include/omp.h' \
        '/usr/local/include/ompt.h' \
        '/usr/local/lib/libomp.dylib'
    return 0
}
