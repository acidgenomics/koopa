#!/usr/bin/env bash

main() {
    # """
    # Install OpenMP for Xcode library.
    # @note Updated 2025-01-31.
    #
    # Useful for optimizing performance of 'data.table' package.
    #
    # @seealso
    # - https://mac.r-project.org/openmp/
    # - https://github.com/Rdatatable/data.table/wiki/Installation
    # """
    local -A app dict
    app['tar']="$(koopa_locate_tar --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    dict['platform']='darwin'
    dict['release']='Release' # or 'Debug'.
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    case "${dict['version']}" in
        '11.'* | '12.'* | '14.'* | '15.'* | '16.'* | '17.'* | '18.'* | '19.'*)
            dict['platform_version']='20'
            ;;
        '13.'*)
            dict['platform_version']='21'
            ;;
        '7.'* | '8.'* | '9.'* | '10.'*)
            dict['platform_version']='17'
            ;;
        *)
            koopa_stop "Unsupported LLVM version: '${dict['version']}'."
            ;;
    esac
    dict['url']="https://mac.r-project.org/openmp/openmp-${dict['version']}-\
${dict['platform']}${dict['platform_version']}-${dict['release']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_sudo \
        "${app['tar']}" \
            -vxz \
            -f "$(koopa_basename "${dict['url']}")" \
            -C '/'
    koopa_assert_is_file \
        '/usr/local/include/omp-tools.h' \
        '/usr/local/include/omp.h' \
        '/usr/local/include/ompt.h' \
        '/usr/local/lib/libomp.dylib'
    return 0
}
