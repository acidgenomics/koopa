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
    local -A dict
    dict['platform']='darwin'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
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
    dict['url']="https://mac.r-project.org/openmp/openmp-${dict['version']}-\
${dict['platform']}${dict['platform_version']}-${dict['release']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_mv \
        --target-directory="${dict['prefix']}" \
        'src/local/'*
    return 0
}
