#!/usr/bin/env bash

main() {
    # """
    # Install OpenMP library.
    # @note Updated 2022-04-13.
    #
    # Useful for optimizing performance of 'data.table' package.
    #
    # @seealso
    # - https://mac.r-project.org/openmp/
    # - https://github.com/Rdatatable/data.table/wiki/Installation
    # """
    local app
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [sudo]="$(koopa_locate_sudo)"
        [tar]="$(koopa_locate_tar)"
    )
    declare -A dict=(
        [name]='openmp'
        [platform]='darwin'
        [release]='Release' # or 'Debug'.
        [version]="${INSTALL_VERSION:?}"
    )

    case "${dict[version]}" in
        '13.0.0')
            dict[platform_version]='21'
            ;;
        '12.0.1' | \
        '11.0.1')
            dict[platform_version]='20'
            ;;
        '10.0.0' | \
        '9.0.1' | \
        '8.0.1' | \
        '7.1.0')
            dict[platform_version]='17'
            ;;
        *)
            koopa_stop "Unsupported version: '${dict[version]}'."
            ;;
    esac
    dict[file]="${dict[name]}-${dict[version]}-\
${dict[platform]}${dict[platform_version]}-${dict[release]}.tar.gz"
    dict[url]="https://mac.r-project.org/${dict[name]}/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    "${app[sudo]}" "${app[tar]}" -vxz -f "${dict[file]}" -C /
    koopa_assert_is_file \
        '/usr/local/include/omp-tools.h' \
        '/usr/local/include/omp.h' \
        '/usr/local/include/ompt.h' \
        '/usr/local/lib/libomp.dylib'
    return 0
}
